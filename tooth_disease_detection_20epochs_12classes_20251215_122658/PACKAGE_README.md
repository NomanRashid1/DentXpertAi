# Tooth Disease Detection - Colored Overlay Visualization Package

## 🎨 New Feature: Colored Overlay Visualization

This package includes an enhanced visualization system that colors defected teeth with semi-transparent overlays instead of bounding boxes, making it easier to identify and understand dental issues in X-ray images.

## 📦 Package Contents

- `api.py` - Flask REST API server
- `predict_enhanced.py` - Enhanced prediction module with colored overlays
- `predict.py` - Simple prediction script
- `pdf_generator.py` - PDF report generation
- `disease_classifier.py` - Disease classification logic
- `frontend/` - Web interface for testing
- `runs/train/multi_param_dental/weights/` - Trained model weights
- `dataset_samples/` - Sample X-ray images for testing

## 🚀 Quick Start

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

Create a `.env` file or edit the existing one:

```
GEMINI_API_KEY=your_api_key_here
```

### 3. Start the API Server

**Windows:**
```bash
START_API.bat
```

**Linux/Mac:**
```bash
python api.py
```

### 4. Open Frontend

Open `frontend/index.html` in your web browser or navigate to:
```
http://localhost:5000
```

## 📊 API Endpoints

- `GET /api/health` - Health check
- `POST /api/predict` - Get JSON predictions with colored overlay images
- `POST /api/predict-pdf` - Get PDF report with colored overlay visualization
- `POST /api/batch-predict` - Process multiple images
- `GET /api/stats` - API statistics
- `GET /api/image/<filename>` - Serve annotated images

## 🎨 Colored Overlay Visualization

The new visualization system:
- Highlights defected teeth with semi-transparent colored overlays (50% opacity)
- Uses vibrant colors for better visibility
- Displays disease labels with clear backgrounds
- Maintains smart label positioning to avoid overlaps
- Provides better visual context compared to bounding boxes

## 🧪 Testing

### Test with Sample Images

```bash
python predict_enhanced.py
```

Select an image from `dataset_samples/` when prompted.

### Test API

```bash
curl -X POST -F "file=@dataset_samples/test.jpg" http://localhost:5000/api/predict
```

## 📚 Documentation

- `README_DEPLOYMENT.md` - Detailed deployment guide
- `QUICKSTART.md` - Quick start guide
- `HOW_TO_GET_PDF.md` - PDF generation guide
- `PERFORMANCE_GRAPHS_REPORT.md` - Model performance metrics

## 🔧 System Requirements

- Python 3.8+
- 4GB RAM minimum
- 2GB disk space
- GPU recommended (optional)

## 📞 Support

For issues or questions, refer to the documentation files included in this package.

## 🎯 Features

- ✅ Multi-parameter tooth disease detection
- ✅ Colored overlay visualization
- ✅ AI-powered report generation (using Gemini)
- ✅ PDF report export
- ✅ RESTful API
- ✅ Web interface
- ✅ Batch processing support
- ✅ Disease severity classification
- ✅ Treatment recommendations

---

**Version:** 2.0 (Colored Overlay Edition)  
**Created:** 2025-12-15 12:26:59
