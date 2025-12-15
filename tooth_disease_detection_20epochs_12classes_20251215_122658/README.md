# Multi-Parameter Tooth Disease Detection System

**Complete AI-powered dental X-ray analysis system** that detects tooth numbers, disease types, severity levels, and generates professional reports with color-coded visualizations.

---

## 🎯 System Capabilities

This system can predict **MULTIPLE PARAMETERS** for each detected tooth:

1. **Tooth Number** (1-32 based on FDI notation)
2. **Disease Type** (Cavity, Fracture, Abscess, Periodontitis, etc.)
3. **Severity Level** (Mild, Moderate, Severe, Critical)
4. **Affected Area** (Crown, Root, Gum, Nerve)
5. **Confidence Score** (0-100%)
6. **Treatment Recommendations** (AI-generated)
7. **Urgency Level** (Low, Moderate, High, Urgent)

### Visual Output Features
- ✅ Color-coded bounding boxes (different color for each disease)
- ✅ Disease names displayed above each tooth
- ✅ Tooth numbers and confidence scores
- ✅ Comprehensive PDF/CSV/JSON reports
- ✅ AI-powered insights (using Gemini AI)

---

## 📁 Project Structure

```
final year project/
├── prepare_dataset.py          # Dataset preparation from JSON annotations
├── disease_classifier.py       # Disease taxonomy and classification logic
├── train.py                    # Enhanced training script
├── predict_enhanced.py         # Multi-parameter prediction
├── evaluate_enhanced.py        # Comprehensive evaluation
├── requirements.txt            # Python dependencies
├── dataset/                    # Prepared dataset (auto-generated)
│   ├── images/
│   │   ├── train/
│   │   ├── val/
│   │   └── test/
│   ├── labels/
│   │   ├── train/
│   │   ├── val/
│   │   └── test/
│   └── data.yaml
├── runs/                       # Training outputs
└── results_pridects/           # Prediction outputs
```

---

## 🚀 Step-by-Step Usage Guide

### Step 1: Install Dependencies

```bash
# Create virtual environment (recommended)
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install requirements
pip install -r requirements.txt
```

### Step 2: Prepare Dataset

Convert your Teeth Segmentation JSON files to YOLO format:

```bash
python prepare_dataset.py
```

**This script will:**
- Parse JSON annotations from `Teeth Segmentation JSON/`
- Extract tooth segmentation polygons
- Convert to YOLO bounding box format
- Split into train/val/test sets (70/20/10)
- Create `dataset/data.yaml` configuration

**Output:**
```
dataset/
├── images/train/  (420 images)
├── images/val/    (120 images)
├── images/test/   (58 images)
├── labels/train/  (420 labels)
├── labels/val/    (120 labels)
├── labels/test/   (58 labels)
└── data.yaml
```

### Step 3: Train the Model

Train YOLOv8 model on your prepared dataset:

```bash
python train.py
```

**Training Configuration:**
- Model: YOLOv8m (medium) for better multi-class accuracy
- Epochs: 100 (with early stopping)
- Image Size: 640x640
- Batch Size: 8 (adjust based on your GPU)
- Augmentation: Comprehensive (rotation, scaling, flip, HSV, etc.)

**Expected Training Time:**
- With GPU (RTX 3060/3070): ~2-4 hours
- Without GPU: 10-20+ hours (not recommended)

**Outputs:**
```
runs/train/multi_param_dental/
├── weights/
│   ├── best.pt    (best model weights)
│   └── last.pt    (last epoch weights)
├── results.csv    (training metrics)
└── *.png          (training curves)
```

### Step 4: Make Predictions

Run predictions on new dental X-ray images:

```bash
python predict_enhanced.py
```

**What happens:**
1. File dialog opens to select an X-ray image
2. Model detects all visible teeth
3. For each tooth, predicts:
   - Tooth number
   - Disease type
   - Severity level
   - Affected area
   - Confidence score
4. Generates annotated image with color-coded boxes
5. Creates comprehensive reports (CSV, JSON, TXT)

**Output Files:**
```
results_pridects/
├── {unique_id}.jpg          # Annotated image
├── {unique_id}.json         # Detailed JSON report
├── {unique_id}.txt          # Human-readable report
└── report.csv               # Cumulative CSV log
```

### Step 5: Evaluate Model Performance

Evaluate model on test set:

```bash
python evaluate_enhanced.py
```

**Generates:**
- Confusion matrix
- Training curves (loss, mAP, precision, recall)
- Per-class performance metrics
- Detection examples
- Comprehensive metrics report

---

## 🎨 Disease Color Coding

Each disease type has a unique color:

| Disease | Color | Hex Code |
|---------|-------|----------|
| Healthy | Green | #00FF00 |
| Cavity | Red | #FF0000 |
| Fracture | Orange | #FF8800 |
| Abscess | Purple | #9932CC |
| Periodontitis | Dark Red | #8B0000 |
| Gingivitis | Pink | #FF69B4 |
| Root Canal Needed | Blue | #0000FF |
| Impaction | Gold | #FFD700 |
| Erosion | Orange | #FFA500 |
| Calculus | Brown | #A0522D |
| Pulpitis | Crimson | #DC143C |

---

## 📊 Expected Performance

### Current System (2 parameters)
- Classes: 2
- mAP@0.5: ~70%

### Enhanced System (Multi-parameter)
- Tooth Detection: 32 classes (teeth 1-32)
- Disease Classification: 10+ disease types
- Expected mAP@0.5: >85% for tooth detection
- Expected mAP@0.5: >80% for disease classification

---

## 🤖 AI Integration (Optional)

To enable AI-powered insights with Gemini:

1. Create a `.env` file in the project directory:
```
GEMINI_API_KEY=your_api_key_here
```

2. Get a free API key from: https://makersuite.google.com/app/apikey

**AI Features:**
- Natural language report generation
- Treatment recommendations
- Risk assessment
- Preventive care suggestions

---

## 📖 How the System Works

### 1. **Dataset Preparation**
```
JSON Annotations → Polygon Extraction → Bounding Box Conversion → YOLO Format
```

### 2. **Training Pipeline**
```
Pretrained YOLOv8m → Multi-Class Training → Tooth Number Detection
```

### 3. **Prediction Pipeline**
```
X-Ray Input → YOLO Detection → Disease Classification → Color-Coded Visualization
```

### 4. **Report Generation**
```
Detections → Parameter Extraction → AI Enhancement → Multi-Format Reports
```

---

## 💡 Key Improvements Over Basic System

| Feature | Basic System | Enhanced System |
|---------|--------------|-----------------|
| Parameters Predicted | 2 | 7+ |
| Classes | 2 | 32+ |
| Visualization | Single color | Color-coded by disease |
| Reports | Basic text | CSV, JSON, TXT, AI-enhanced |
| Disease Types | Limited | 10+ comprehensive |
| Severity Assessment | No | Yes (4 levels) |
| Treatment Recommendations | No | Yes (AI-powered) |
| Urgency Levels | No | Yes (4 levels) |

---

## 🔧 Troubleshooting

### Issue: "Model not found"
**Solution:** Run training first: `python train.py`

### Issue: "Dataset configuration not found"
**Solution:** Run dataset preparation: `python prepare_dataset.py`

### Issue: "CUDA out of memory"
**Solution:** Reduce batch size in `train.py` (e.g., `BATCH_SIZE = 4`)

### Issue: "No JSON files found"
**Solution:** Update paths in `prepare_dataset.py` to match your dataset location

---

## 📝 Citation

If you use this system, please cite:

```bibtex
@software{tooth_disease_detection,
  title={Multi-Parameter Tooth Disease Detection System},
  author={Your Name},
  year={2025},
  description={AI-powered dental X-ray analysis with multi-parameter prediction}
}
```

---

## 📧 Support

For questions or issues:
1. Check the implementation plan: `implementation_plan.md`
2. Review training logs in `runs/train/`
3. Check evaluation results in `evaluation_results/`

---

## 🎓 Future Enhancements

- [ ] Real-time video analysis
- [ ] Integration with DICOM format
- [ ] Multi-view X-ray fusion
- [ ] 3D reconstruction from 2D X-rays
- [ ] Mobile app deployment
- [ ] Cloud-based processing
- [ ] Historical tracking and progression analysis

---

**Version:** 2.0  
**Last Updated:** 2025  
**License:** MIT
