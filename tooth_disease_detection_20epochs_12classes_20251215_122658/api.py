"""
REST API for Tooth Disease Detection
Provides endpoints to upload X-ray images and receive PDF reports
"""

from dotenv import load_dotenv
load_dotenv()  # Load .env file BEFORE other imports

from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from werkzeug.utils import secure_filename
import os
import uuid
from email_service import email_service
from predict_enhanced import ToothDiseasePredictor
from pdf_generator import generate_pdf_report
import traceback

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'bmp', 'tiff'}
MAX_FILE_SIZE = 16 * 1024 * 1024  # 16MB

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# Create upload directory
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Initialize predictor
predictor = ToothDiseasePredictor(
    model_path="runs/train/multi_param_dental/weights/best.pt",
    gemini_api_key=os.getenv("GEMINI_API_KEY")
)


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Tooth Disease Detection API',
        'version': '1.0.0'
    })


@app.route('/api/predict', methods=['POST'])
def predict():
    """
    Predict endpoint - accepts X-ray image, returns JSON results
    
    Request:
        - file: X-ray image file (multipart/form-data)
        - confidence_threshold: Optional, default 0.25
    
    Response:
        - JSON with prediction results
    """
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        # Check if file is selected
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Check if file type is allowed
        if not allowed_file(file.filename):
            return jsonify({
                'error': f'Invalid file type. Allowed types: {", ".join(ALLOWED_EXTENSIONS)}'
            }), 400
        
        # Save uploaded file
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4().hex}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(filepath)
        
        # Get confidence threshold
        conf_threshold = float(request.form.get('confidence_threshold', 0.25))
        
        # Run prediction
        results = predictor.predict(filepath, conf_threshold=conf_threshold)
        
        # Return results
        return jsonify({
            'success': True,
            'results': results
        })
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'error': str(e),
            'success': False
        }), 500


@app.route('/api/predict-pdf', methods=['POST'])
def predict_pdf():
    """
    Predict and generate PDF report endpoint
    
    Request:
        - file: X-ray image file (multipart/form-data)
        - confidence_threshold: Optional, default 0.25
        - include_ai_insights: Optional, default false
    
    Response:
        - PDF file download
    """
    try:
        # Check if file is present
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        # Check if file is selected
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Check if file type is allowed
        if not allowed_file(file.filename):
            return jsonify({
                'error': f'Invalid file type. Allowed types: {", ".join(ALLOWED_EXTENSIONS)}'
            }), 400
        
        # Save uploaded file
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4().hex}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(filepath)
        
        # Get parameters
        conf_threshold = float(request.form.get('confidence_threshold', 0.25))
        
        # Run prediction
        print(f"🔍 Processing: {filename}")
        results = predictor.predict(filepath, conf_threshold=conf_threshold)
        
        # Generate PDF report
        print(f"📄 Generating PDF report...")
        pdf_path = generate_pdf_report(results)
        
        # Get filename
        pdf_filename = f"dental_report_{results['unique_id'][:8]}.pdf"
        
        # Read PDF file into memory
        with open(pdf_path, 'rb') as f:
            pdf_data = f.read()
        
        pdf_size = len(pdf_data)
        print(f"📤 Sending PDF: {pdf_filename} ({pdf_size} bytes)")
        
        # Use Flask Response directly with BytesIO for reliable streaming
        from flask import Response
        from io import BytesIO
        
        # Create BytesIO stream from PDF data
        pdf_stream = BytesIO(pdf_data)
        
        # Create response with generator to ensure complete transfer
        def generate():
            while True:
                chunk = pdf_stream.read(8192)  # 8KB chunks
                if not chunk:
                    break
                yield chunk
        
        response = Response(
            generate(),
            mimetype='application/pdf',
            headers={
                'Content-Disposition': f'attachment; filename="{pdf_filename}"',
                'Content-Length': str(pdf_size),
                'Content-Type': 'application/pdf',
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'X-Content-Type-Options': 'nosniff',
            }
        )
        
        return response
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'error': str(e),
            'success': False
        }), 500


@app.route('/api/batch-predict', methods=['POST'])
def batch_predict():
    """
    Batch prediction endpoint - accepts multiple images
    
    Request:
        - files[]: Multiple X-ray image files
        - confidence_threshold: Optional, default 0.25
    
    Response:
        - JSON with results for all images
    """
    try:
        # Check if files are present
        if 'files[]' not in request.files:
            return jsonify({'error': 'No files provided'}), 400
        
        files = request.files.getlist('files[]')
        
        if len(files) == 0:
            return jsonify({'error': 'No files selected'}), 400
        
        # Get confidence threshold
        conf_threshold = float(request.form.get('confidence_threshold', 0.25))
        
        results = []
        
        # Process each file
        for file in files:
            if file and allowed_file(file.filename):
                # Save file
                filename = secure_filename(file.filename)
                unique_filename = f"{uuid.uuid4().hex}_{filename}"
                filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
                file.save(filepath)
                
                # Run prediction
                prediction = predictor.predict(filepath, conf_threshold=conf_threshold)
                
                results.append({
                    'filename': filename,
                    'results': prediction
                })
        
        return jsonify({
            'success': True,
            'total_processed': len(results),
            'results': results
        })
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'error': str(e),
            'success': False
        }), 500




@app.route('/api/image/<path:filename>', methods=['GET'])
def serve_image(filename):
    """Serve annotated images"""
    try:
        image_path = os.path.join('results_pridects', filename)
        if os.path.exists(image_path):
            return send_file(image_path, mimetype='image/jpeg')
        else:
            return jsonify({'error': 'Image not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get API usage statistics"""
    return jsonify({
        'model_path': predictor.model_path,
        'total_classes': len(predictor.model.names),
        'classes': predictor.model.names,
        'supported_formats': list(ALLOWED_EXTENSIONS),
        'max_file_size_mb': MAX_FILE_SIZE / (1024 * 1024)
    })

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



if __name__ == '__main__':
    print("="*70)
    print("🦷 TOOTH DISEASE DETECTION API")
    print("="*70)
    print(f"\n✅ Model loaded: {predictor.model_path}")
    print(f"✅ Classes: {len(predictor.model.names)}")
    print(f"✅ Upload folder: {UPLOAD_FOLDER}")
    print(f"\n🌐 API Endpoints:")
    print(f"   • GET  /api/health          - Health check")
    print(f"   • POST /api/predict         - Get JSON predictions")
    print(f"   • POST /api/predict-pdf     - Get PDF report")
    print("  POST /api/send-email    - Send email with PDF")
    print(f"   • POST /api/batch-predict   - Batch processing")
    print(f"   • GET  /api/stats           - API statistics")
    print(f"\n🚀 Starting server on http://localhost:5000")
    print("="*70)
    print()
    
    try:
        from waitress import serve
        print("✅ Using Waitress production server")
        serve(app, host='0.0.0.0', port=8080, threads=4, channel_timeout=300)
    except ImportError:
        print("⚠️  Waitress not found, falling back to Flask dev server")
        print("   Install waitress: pip install waitress")
        app.run(debug=True, host='0.0.0.0', port=8080)
