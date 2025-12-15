# Quick Start Guide - Multi-Parameter Tooth Disease Detection

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Python 3.8 or higher
- NVIDIA GPU (recommended, but not required)
- 8GB RAM minimum (16GB recommended)
- Your dental X-ray images and segmentation JSON files

---

## Step-by-Step Setup

### 1️⃣ Install Dependencies (2 minutes)

Open PowerShell in the project directory and run:

```powershell
# Create and activate virtual environment
python -m venv venv
.\venv\Scripts\activate

# Install all required packages
pip install -r requirements.txt

# Verify installation
python -c "import ultralytics; print('✅ Installation successful!')"
```

---

### 2️⃣ Prepare Your Dataset (5-10 minutes)

```powershell
# Run dataset preparation script
python prepare_dataset.py
```

**What this does:**
- Reads your JSON annotations from `Teeth Segmentation JSON/`
- Converts polygons to YOLO bounding boxes
- Splits data: 70% train, 20% validation, 10% test
- Creates `dataset/data.yaml` configuration

**Expected output:**
```
✅ Created class mapping for 32 tooth classes
✅ train: 420 files processed
✅ val: 120 files processed
✅ test: 58 files processed
✅ Generated dataset/data.yaml
```

---

### 3️⃣ Train the Model (2-4 hours with GPU)

```powershell
# Start training
python train.py
```

**Training will:**
- Use YOLOv8 medium model
- Train for 100 epochs (early stopping enabled)
- Save best model to `runs/train/multi_param_dental/weights/best.pt`

**Monitor progress:**
- Watch terminal output for metrics
- Check `runs/train/multi_param_dental/` for plots

---

### 4️⃣ Make Predictions (instant)

```powershell
# Run prediction with GUI file selector
python predict_enhanced.py
```

**OR use command line:**

```python
from predict_enhanced import ToothDiseasePredictor

# Initialize predictor
predictor = ToothDiseasePredictor(
    model_path="runs/train/multi_param_dental/weights/best.pt",
    gemini_api_key=None  # Optional
)

# Predict on an image
results = predictor.predict("path/to/xray.jpg")

# Results contain:
# - Annotated image with color-coded boxes
# - Tooth numbers for each detection
# - Disease types and severity
# - Confidence scores
# - Treatment recommendations
```

---

### 5️⃣ Evaluate Model Performance

```powershell
# Run comprehensive evaluation
python evaluate_enhanced.py
```

**Generates:**
- `evaluation_results/confusion_matrix.png`
- `evaluation_results/training_curves.png`
- `evaluation_results/per_class_metrics.png`
- `evaluation_results/evaluation_metrics.txt`

---

## 📊 Understanding the Output

### Prediction Output Structure

```json
{
  "unique_id": "abc-123-def-456",
  "total_detections": 12,
  "detections": [
    {
      "tooth_number": 14,
      "tooth_name": "Upper Right First Premolar",
      "disease_type": "Cavity (Caries)",
      "severity": "Moderate",
      "affected_area": "Crown",
      "confidence": 0.89,
      "color": "#FF0000",
      "recommendations": [
        "Dental filling required",
        "Regular dental checkups recommended",
        "Improve oral hygiene"
      ],
      "urgency": "MODERATE - Schedule appointment within 2-4 weeks"
    }
    // ... more detections
  ],
  "summary": {
    "total_teeth": 12,
    "disease_distribution": {
      "Healthy": 8,
      "Cavity": 3,
      "Periodontitis": 1
    }
  }
}
```

---

## 🎯 Common Workflows

### Testing on a Single Image

```powershell
# Quick prediction
python predict_enhanced.py
# → Select image in file dialog
# → View results in results_pridects/
```

### Batch Processing Multiple Images

```python
from predict_enhanced import ToothDiseasePredictor
from pathlib import Path

predictor = ToothDiseasePredictor("runs/train/multi_param_dental/weights/best.pt")

# Process all images in a folder
image_dir = Path("path/to/xray/images")
for img_path in image_dir.glob("*.jpg"):
    results = predictor.predict(str(img_path))
    print(f"✅ Processed {img_path.name}: {results['total_detections']} teeth detected")
```

### Customizing Disease Detection

Edit `disease_classifier.py` to:
- Add new disease types
- Modify color coding
- Update treatment recommendations
- Adjust severity thresholds

---

## ⚙️ Configuration Options

### Training Configuration (`train.py`)

```python
MODEL_SIZE = 'yolov8m.pt'      # Options: n, s, m, l, x
EPOCHS = 100                    # Adjust based on dataset size
IMG_SIZE = 640                  # 640 is standard, 1280 for high-res
BATCH_SIZE = 8                  # Reduce if GPU memory issues
LEARNING_RATE = 0.001          # Lower for fine-tuning
```

### Prediction Configuration (`predict_enhanced.py`)

```python
conf_threshold = 0.25   # Confidence threshold (lower = more detections)
```

---

## 📈 Performance Expectations

### Small Dataset (< 500 images)
- Training time: 1-2 hours
- Expected mAP@0.5: 75-85%
- Recommended epochs: 50-100

### Medium Dataset (500-2000 images)
- Training time: 3-6 hours
- Expected mAP@0.5: 85-92%
- Recommended epochs: 100-150

### Large Dataset (> 2000 images)
- Training time: 6-12 hours
- Expected mAP@0.5: 92-96%
- Recommended epochs: 150-200

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| ImportError: No module named 'ultralytics' | Run `pip install -r requirements.txt` |
| CUDA out of memory | Reduce `BATCH_SIZE` in train.py to 4 or 2 |
| Model not found | Train first with `python train.py` |
| Dataset not found | Run `python prepare_dataset.py` first |
| Low accuracy | More training data, increase epochs, use larger model |

---

## 🎓 Next Steps

1. **Improve Accuracy:**
   - Collect more training data
   - Use larger model (yolov8l.pt or yolov8x.pt)
   - Increase training epochs
   - Fine-tune augmentation parameters

2. **Add Disease Classification:**
   - Label your dataset with disease types
   - Train separate disease classification model
   - Integrate with tooth detection

3. **Deploy the System:**
   - Create web interface with Flask/FastAPI
   - Build desktop app with PyQt/Tkinter
   - Containerize with Docker

---

## 📞 Getting Help

1. Check logs in `runs/train/multi_param_dental/`
2. Review `README.md` for detailed documentation
3. Examine `implementation_plan.md` for system architecture
4. Debug with verbose mode: `python script.py --verbose`

---

**Ready to start?** Run: `python prepare_dataset.py`
