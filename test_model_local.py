import os
import sys
from pathlib import Path
from ultralytics import YOLO

# Setup paths
PROJECT_ROOT = Path(r"c:\Users\UseR\Documents\GitHub\DentXpertAi")
MODEL_PATH = PROJECT_ROOT / "backend/model/best.pt"
TEST_IMAGE_PATH = Path(r"C:\Users\UseR\.gemini\antigravity\brain\86658d40-6d0f-4f31-b3fa-aff3705b0b69\uploaded_image_1765540769025.jpg")

print("="*60)
print("🔍 TESTING MODEL INTEGRATION")
print("="*60)

# 1. Check Model File
if not MODEL_PATH.exists():
    print(f"❌ Model file NOT found at: {MODEL_PATH}")
    sys.exit(1)
print(f"✅ Model file found: {MODEL_PATH}")

# 2. Check Test Image
if not TEST_IMAGE_PATH.exists():
    print(f"❌ Test image NOT found at: {TEST_IMAGE_PATH}")
    # Try to find any jpg in the repo as backup
    sample_images = list(PROJECT_ROOT.glob("**/*.jpg"))
    if sample_images:
        TEST_IMAGE_PATH = sample_images[0]
        print(f"⚠️  Using alternative image: {TEST_IMAGE_PATH}")
    else:
        sys.exit(1)

# 3. Load Model
try:
    print("\n⏳ Loading YOLO model...")
    model = YOLO(str(MODEL_PATH))
    print(f"✅ Model loaded successfully!")
    print(f"   Classes: {model.names}")
except Exception as e:
    print(f"❌ FAILED TO LOAD MODEL: {e}")
    sys.exit(1)

# 4. Run Prediction
try:
    print("\n⏳ Running prediction...")
    results = model.predict(source=str(TEST_IMAGE_PATH), conf=0.25)
    
    print("\n📊 PREDICTION RESULTS:")
    for result in results:
        print(f"   - Detected {len(result.boxes)} objects")
        for box in result.boxes:
            class_id = int(box.cls)
            class_name = model.names[class_id]
            conf = float(box.conf)
            print(f"     • {class_name}: {conf:.2f}")

    print("\n✅ INTEGRATION TEST PASSED")

except Exception as e:
    print(f"❌ PREDICTION FAILED: {e}")
    import traceback
    traceback.print_exc()
