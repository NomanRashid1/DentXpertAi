
# Package Verification Script
# Run this to verify the package is complete

import os
import sys

def check_file(filepath):
    if os.path.exists(filepath):
        print(f"✅ {filepath}")
        return True
    else:
        print(f"❌ {filepath} - MISSING")
        return False

def check_directory(dirpath):
    if os.path.exists(dirpath) and os.path.isdir(dirpath):
        file_count = len([f for f in os.listdir(dirpath) if os.path.isfile(os.path.join(dirpath, f))])
        print(f"✅ {dirpath} ({file_count} files)")
        return True
    else:
        print(f"❌ {dirpath} - MISSING")
        return False

print("\n" + "="*70)
print("PACKAGE VERIFICATION")
print("="*70)

required_files = [
    "api.py",
    "predict_enhanced.py",
    "pdf_generator.py",
    "disease_classifier.py",
    "requirements.txt",
]

required_dirs = [
    "frontend",
    "runs/train/multi_param_dental/weights",
]

print("\nChecking required files...")
files_ok = all(check_file(f) for f in required_files)

print("\nChecking required directories...")
dirs_ok = all(check_directory(d) for d in required_dirs)

print("\n" + "="*70)
if files_ok and dirs_ok:
    print("✅ VERIFICATION PASSED - Package is complete!")
else:
    print("❌ VERIFICATION FAILED - Some files/directories are missing")
    sys.exit(1)
print("="*70 + "\n")
