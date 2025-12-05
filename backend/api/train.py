"""
Enhanced Multi-Parameter Tooth Disease Detection Training Script
Supports multi-class tooth number detection and disease classification
"""

import torch
from ultralytics import YOLO
import os
from pathlib import Path


def main():
    """Main training function with enhanced multi-class support"""
    
    print("=" * 70)
    print("MULTI-PARAMETER TOOTH DISEASE DETECTION - TRAINING")
    print("=" * 70)
    
    # Check GPU availability
    if torch.cuda.is_available():
        print(f"\n✅ Training on GPU: {torch.cuda.get_device_name(0)}")
        print(f"   GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
        device = '0'
    else:
        print("\n⚠️ GPU not available, training will run on CPU")
        print("   WARNING: Training will be significantly slower")
        device = 'cpu'
    
    # Configuration
    # Use larger model for better multi-class performance
    # Options: yolov8n.pt (smallest), yolov8s.pt, yolov8m.pt (recommended), yolov8l.pt, yolov8x.pt (largest)
    MODEL_SIZE = 'yolov8m.pt'  # Medium model for better accuracy
    
    # Dataset path - update this to your prepared dataset location
    DATA_YAML = "dataset/data.yaml"  # Relative path
    
    # Check if dataset exists
    if not os.path.exists(DATA_YAML):
        print(f"\n❌ ERROR: Dataset configuration not found at {DATA_YAML}")
        print("   Please run prepare_dataset.py first to prepare your dataset")
        print("   Example: python prepare_dataset.py")
        return
    
    print(f"\n📊 Dataset: {DATA_YAML}")
    print(f"🤖 Model: {MODEL_SIZE}")
    
    # Load pretrained model
    print(f"\n📥 Loading pretrained model: {MODEL_SIZE}")
    model = YOLO(MODEL_SIZE)
    
    # Training hyperparameters
    EPOCHS = 10                 # Training for 10 epochs on local system
    IMG_SIZE = 640              # Standard YOLO image size
    BATCH_SIZE = 4              # Reduced for CPU training (use 8+ on GPU)
    LEARNING_RATE = 0.001       # Initial learning rate
    PATIENCE = 20               # Early stopping patience
    
    print(f"\n⚙️ Training Configuration:")
    print(f"   Epochs: {EPOCHS}")
    print(f"   Image Size: {IMG_SIZE}x{IMG_SIZE}")
    print(f"   Batch Size: {BATCH_SIZE}")
    print(f"   Learning Rate: {LEARNING_RATE}")
    print(f"   Patience: {PATIENCE}")
    print(f"   Device: {device}")
    
    # Start training
    print(f"\n🚀 Starting training...")
    print("=" * 70)
    
    try:
        results = model.train(
            # Dataset
            data=DATA_YAML,
            
            # Training duration
            epochs=EPOCHS,
            patience=PATIENCE,          # Early stopping if no improvement
            
            # Image settings
            imgsz=IMG_SIZE,
            
            # Batch settings
            batch=BATCH_SIZE,
            
            # Optimization
            optimizer='AdamW',          # AdamW optimizer
            lr0=LEARNING_RATE,          # Initial learning rate
            lrf=0.01,                   # Final learning rate (lr0 * lrf)
            momentum=0.937,             # SGD momentum/Adam beta1
            weight_decay=0.0005,        # Optimizer weight decay
            
            # Augmentation (important for medical images)
            hsv_h=0.015,                # HSV-Hue augmentation
            hsv_s=0.4,                  # HSV-Saturation augmentation
            hsv_v=0.4,                  # HSV-Value augmentation
            degrees=10.0,               # Rotation augmentation (degrees)
            translate=0.1,              # Translation augmentation
            scale=0.3,                  # Scaling augmentation
            shear=5.0,                  # Shear augmentation (degrees)
            perspective=0.0,            # Perspective augmentation
            flipud=0.0,                 # Vertical flip (0 for X-rays)
            fliplr=0.5,                 # Horizontal flip (50% chance)
            mosaic=0.5,                 # Mosaic augmentation
            mixup=0.1,                  # Mixup augmentation
            
            # Output settings
            project="runs/train",
            name="multi_param_dental",
            exist_ok=True,
            
            # Performance
            device=device,
            workers=4,                  # Data loading workers
            amp=True,                   # Automatic Mixed Precision
            
            # Validation
            val=True,
            save=True,
            save_period=10,             # Save checkpoint every N epochs
            
            # Logging
            verbose=True,
            plots=True,                 # Generate training plots
        )
        
        print("\n" + "=" * 70)
        print("✅ TRAINING COMPLETED SUCCESSFULLY!")
        print("=" * 70)
        
        # Print results location
        save_dir = Path("runs/train/multi_param_dental")
        print(f"\n📁 Results saved to: {save_dir}")
        print(f"   Best weights: {save_dir}/weights/best.pt")
        print(f"   Last weights: {save_dir}/weights/last.pt")
        print(f"   Training plots: {save_dir}/")
        
        # Print final metrics if available
        if hasattr(results, 'results_dict'):
            print(f"\n📊 Final Metrics:")
            metrics = results.results_dict
            if 'metrics/mAP50(B)' in metrics:
                print(f"   mAP@0.5: {metrics['metrics/mAP50(B)']:.4f}")
            if 'metrics/mAP50-95(B)' in metrics:
                print(f"   mAP@0.5:0.95: {metrics['metrics/mAP50-95(B)']:.4f}")
        
        print("\n💡 Next steps:")
        print("   1. Review training plots in the results directory")
        print("   2. Run evaluation: python evaluate.py")
        print("   3. Test predictions: python predict.py")
        
    except Exception as e:
        print(f"\n❌ ERROR during training: {e}")
        print("   Check your dataset configuration and GPU availability")
        raise


if __name__ == '__main__':
    main()
