"""
Tooth Detection API Server - FIXED VERSION
Production-ready API for mobile app integration
"""

from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
import os
from pathlib import Path
import uuid
import traceback
import io
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Import prediction and PDF modules
from predict_enhanced import ToothDiseasePredictor
from pdf_generator import generate_pdf_report
from email_service import email_service

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
RESULTS_FOLDER = 'results_pridects'
MODEL_PATH = str(Path(__file__).parent.parent / 'model' / 'best.pt')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'bmp', 'tiff'}
MAX_FILE_SIZE = 16 * 1024 * 1024

# Create folders
uploads_dir = Path(__file__).parent.parent / UPLOAD_FOLDER
results_dir = Path(__file__).parent.parent / RESULTS_FOLDER
uploads_dir.mkdir(exist_ok=True)
results_dir.mkdir(exist_ok=True)

# Initialize predictor
print("="*70)
print("TOOTH DETECTION API SERVER")
print("="*70)
print(f"\nInitializing model from: {MODEL_PATH}")

try:
    predictor = ToothDiseasePredictor(model_path=MODEL_PATH, gemini_api_key=os.getenv("GEMINI_API_KEY"))
    print(f"[OK] Model loaded successfully!")
    print(f"[OK] Classes: {len(predictor.model.names)}")
    print(f"[OK] Accuracy: 92.07%% mAP@0.5")
except Exception as e:
    print(f"[ERROR] Failed to load model: {e}")
    traceback.print_exc()
    exit(1)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'healthy',
        'model': 'loaded',
        'version': '1.0',
        'accuracy': '92.07% mAP@0.5',
        'classes': len(predictor.model.names)
    })

@app.route('/api/predict', methods=['POST'])
def predict():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type'}), 400
        
        conf_threshold = float(request.form.get('confidence_threshold', 0.25))
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        filepath = uploads_dir / unique_filename
        file.save(str(filepath))
        
        results = predictor.predict(str(filepath), conf_threshold=conf_threshold)
        os.remove(filepath)
        
        return jsonify({'success': True, 'results': results})
    except Exception as e:
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/predict-pdf', methods=['POST'])
def predict_pdf():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type'}), 400
        
        conf_threshold = float(request.form.get('confidence_threshold', 0.25))
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        filepath = uploads_dir / unique_filename
        file.save(str(filepath))
        
        results = predictor.predict(str(filepath), conf_threshold=conf_threshold)
        pdf_path = generate_pdf_report(results, output_dir=str(results_dir))
        os.remove(filepath)
        
        pdf_filename = f"dental_report_{results['unique_id'][:8]}.pdf"
        
        # Read PDF into memory
        with open(pdf_path, 'rb') as f:
            pdf_data = f.read()
        
        # Return PDF with explicit headers to prevent connection closed errors
        response = app.response_class(
            pdf_data,
            mimetype='application/pdf',
            headers={
                'Content-Disposition': f'attachment; filename={pdf_filename}',
                'Content-Length': str(len(pdf_data)),
                'Content-Type': 'application/pdf',
                'Cache-Control': 'no-cache'
            }
        )
        
        return response
    except Exception as e:
        traceback.print_exc()
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/send-email', methods=['POST'])
def send_email():
    """
    Send dental report email with PDF attachment
    Expects multipart/form-data with:
    - file: PDF file
    - to_email: Recipient email
    - patient_name: Patient's name
    - age: Patient's age (optional)
    - gender: Patient's gender (optional)
    - contact: Patient's contact (optional)
    """
    try:
        # Validate request
        if 'file' not in request.files:
            return jsonify({'success': False, 'error': 'No PDF file provided'}), 400
        
        if 'to_email' not in request.form:
            return jsonify({'success': False, 'error': 'Recipient email required'}), 400
        
        if 'patient_name' not in request.form:
            return jsonify({'success': False, 'error': 'Patient name required'}), 400
        
        # Get request data
        pdf_file = request.files['file']
        to_email = request.form['to_email']
        patient_name = request.form['patient_name']
        
        # Optional patient details
        patient_details = {
            'age': request.form.get('age', 'N/A'),
            'gender': request.form.get('gender', 'N/A'),
            'contact': request.form.get('contact', 'N/A')
        }
        
        # Read PDF bytes
        pdf_bytes = pdf_file.read()
        pdf_filename = pdf_file.filename or 'dental_report.pdf'
        
        # Send email
        result = email_service.send_report_email(
            to_email=to_email,
            patient_name=patient_name,
            pdf_bytes=pdf_bytes,
            pdf_filename=pdf_filename,
            patient_details=patient_details
        )
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 500
            
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False, 
            'error': f'Failed to send email: {str(e)}'
        }), 500

@app.route('/api/image/<path:filename>', methods=['GET'])
def serve_image(filename):
    try:
        image_path = results_dir / filename
        if image_path.exists():
            return send_file(str(image_path), mimetype='image/jpeg')
        return jsonify({'error': 'Image not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats', methods=['GET'])
def get_stats():
    return jsonify({
        'model_version': '1.0',
        'accuracy': '92.07% mAP@0.5',
        'classes': 32,
        'supported_formats': list(ALLOWED_EXTENSIONS),
        'max_file_size_mb': MAX_FILE_SIZE / (1024 * 1024)
    })

if __name__ == '__main__':
    print("\n" + "="*70)
    print("API ENDPOINTS:")
    print("="*70)
    print("  GET  /api/health        - Health check")
    print("  POST /api/predict       - JSON predictions")
    print("  POST /api/predict-pdf   - PDF report")
    print("  POST /api/send-email    - Send email with PDF")
    print("  GET  /api/image/<file>  - Annotated image")
    print("  GET  /api/stats         - Statistics")
    print("\n" + "="*70)
    print("Server starting on http://localhost:5000")
    print("="*70)
    print("\nPress Ctrl+C to stop\n")
    
    # Use waitress production server instead of Flask dev server
    # This fixes connection closed errors with large PDF files
    try:
        from waitress import serve
        print("✅ Using Waitress production server")
        serve(app, host='0.0.0.0', port=5000, threads=4, channel_timeout=300)
    except ImportError:
        print("⚠️  Waitress not found, falling back to Flask dev server")
        print("   Install waitress: pip install waitress")
        app.run(debug=True, host='0.0.0.0', port=5000)
