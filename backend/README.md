# Tooth Detection API - Complete Setup Documentation

## Package Contents

This package contains everything needed to run the Tooth Detection API for mobile app integration.

### Folder Structure
```
Tooth_Detection_API_Package/
├── model/
│   └── best.pt (49.6 MB) - Trained YOLOv8m model (92.07% mAP@0.5)
├── api/
│   ├── api.py - Main API server
│   ├── predict_enhanced.py - Prediction module
│   ├── disease_classifier.py - Disease classification logic
│   └── pdf_generator.py - PDF report generator
├── frontend/
│   └── index.html - Test web UI
├── config/
│   └── .env.example - Environment configuration template
├── docs/
│   └── (documentation files)
├── examples/
│   └── (API usage examples)
├── uploads/ - Temporary upload folder
├── results_pridects/ - Results output folder
└── requirements.txt - Python dependencies
```

---

## 🚀 Quick Start for Beginners

If you are new to Python, just follow these 3 simple steps to get the server running!

### 1. Install Python
Download and install **Python 3.11** from [python.org](https://www.python.org/downloads/).
*   **Important:** Check the box **"Add Python to PATH"** during installation.

### 2. Install Dependencies
Open your terminal (Command Prompt or PowerShell) in this folder and run:

```bash
pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cpu
```

### 3. Run the Server
Start the backend server with this command:

```bash
python api/api.py
```

You should see: `✅ Using Waitress production server` and `Server starting on http://localhost:5000`.

---

## 🛠️ Detailed Setup Guide for Developers

### Prerequisites

- **Python 3.11+** - Required (Download from https://www.python.org/downloads/)
- **pip** - Python package manager (included with Python)
- **Windows, macOS, or Linux** - Any OS supported
- **At least 2GB free disk space** - For dependencies and model

### Step 1: Verify Python Installation

Open terminal/command prompt and verify Python is installed:

```bash
python --version
```

Expected output: `Python 3.11.x` or higher

### Step 2: Navigate to Project Directory

```bash
cd path/to/Tooth_Detection_API_Package
```

### Step 3: Install Dependencies

We have included a `requirements.txt` file to make installation easy.

**For Windows (CPU only - Recommended):**
```bash
pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cpu
```

**For macOS/Linux:**
```bash
pip install -r requirements.txt
```

**Verify installation:**
```bash
pip list
```
Ensure `flask`, `ultralytics`, `opencv-python`, and `waitress` are listed.

### Step 4: Verify Model File Exists

Check that the trained model is present:

```bash
# Windows
dir model\best.pt

# macOS/Linux
ls -lh model/best.pt
```

Expected: `best.pt` file with size ~49.6 MB

If missing, the model file is required for the API to function!

### Step 5: Configure Environment (Optional - For AI Insights)

Create a `.env` file in the root directory for Gemini AI integration:

```bash
# Windows
echo GEMINI_API_KEY=your_api_key_here > .env

# macOS/Linux
echo "GEMINI_API_KEY=your_api_key_here" > .env
```

**Get Gemini API Key:** https://makersuite.google.com/app/apikey

> **Note:** The API works without this key, but AI-generated insights will not be available.

### Step 6: Start the API Server

```bash
python api\api.py
```

Or from the api directory:

```bash
cd api
python api.py
```

**Expected Output:**
```
======================================================================
TOOTH DETECTION API SERVER
======================================================================

Initializing model from: C:\...\model\best.pt
[OK] Model loaded successfully!
[OK] Classes: 32
[OK] Accuracy: 92.07% mAP@0.5

======================================================================
API ENDPOINTS:
======================================================================
  GET  /api/health        - Health check
  POST /api/predict       - JSON predictions
  POST /api/predict-pdf   - PDF report
  GET  /api/image/<file>  - Annotated image
  GET  /api/stats         - Statistics

======================================================================
Server starting on http://localhost:5000
======================================================================

Press Ctrl+C to stop

 * Running on http://127.0.0.1:5000
 * Running on http://192.168.x.x:5000
```

### Step 7: Test the API

#### Option 1: Browser Test
Open your browser and navigate to:
```
http://localhost:5000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "model": "loaded",
  "version": "1.0",
  "accuracy": "92.07% mAP@0.5",
  "classes": 32
}
```

#### Option 2: Command Line Test (curl)
```bash
curl http://localhost:5000/api/health
```

#### Option 3: Test with Frontend
Open the test web interface:
```
frontend/index.html
```
Double-click the file to open in your browser.

### Step 8: Stop the Server

Press `Ctrl+C` in the terminal where the server is running.

---

## 📋 Complete Command Summary

For quick copy-paste installation (run in order):

```bash
# Navigate to project
cd path/to/Tooth_Detection_API_Package_FINAL

# Install PyTorch (CPU - Stable)
pip install torch==2.1.0+cpu torchvision==0.16.0+cpu --index-url https://download.pytorch.org/whl/cpu

# Install NumPy (Compatible version)
pip install numpy==1.26.4

# Install all other dependencies
pip install flask flask-cors ultralytics pillow opencv-python reportlab google-generativeai python-dotenv pyyaml scikit-learn scipy tqdm werkzeug

# Start server
python api\api.py
```

---

## API Endpoints

### Health Check
```http
GET /api/health
```

**Response:**
```json
{
  "status": "healthy",
  "model": "loaded",
  "version": "1.0",
  "accuracy": "92.07% mAP@0.5"
}
```

### Predict (JSON Response)
```http
POST /api/predict
Content-Type: multipart/form-data

Parameters:
- file: Image file (PNG, JPG, JPEG, BMP, TIFF)
- confidence_threshold: 0.0-1.0 (optional, default: 0.25)
```

**Response:**
```json
{
  "success": true,
  "results": {
    "unique_id": "abc123...",
    "timestamp": "2025-11-27 12:00:00",
    "total_detections": 28,
    "detections": [
      {
        "tooth_number": "1",
        "disease_type": "Healthy",
        "severity": "None",
        "affected_area": "None",
        "confidence": 0.85,
        "bbox": [x1, y1, x2, y2],
        "color": [r, g, b],
        "recommendations": [...],
        "urgency": "Low"
      },
      ...
    ],
    "summary": {
      "total_teeth": 28,
      "healthy_teeth": 15,
      "diseased_teeth": 13,
      "disease_distribution": {...}
    },
    "output_image": "path/to/annotated/image.jpg"
  }
}
```

### Predict with PDF Report
```http
POST /api/predict-pdf
Content-Type: multipart/form-data

Parameters:
- file: Image file
- confidence_threshold: 0.0-1.0 (optional)
```

**Response:** PDF file download

### Get Annotated Image
```http
GET /api/image/<filename>
```

**Response:** JPEG image

### Get Statistics
```http
GET /api/stats
```

**Response:**
```json
{
  "model_version": "1.0",
  "accuracy": "92.07% mAP@0.5",
  "classes": 32,
  "supported_formats": ["png", "jpg", "jpeg", "bmp", "tiff"],
  "max_file_size_mb": 16
}
```

---

## Mobile App Integration Examples

### Android (Kotlin)

```kotlin
fun uploadImage(imageFile: File) {
    val client = OkHttpClient()
    
    val requestBody = MultipartBody.Builder()
        .setType(MultipartBody.FORM)
        .addFormDataPart("file", imageFile.name,
            imageFile.asRequestBody("image/*".toMediaTypeOrNull()))
        .addFormDataPart("confidence_threshold", "0.25")
        .build()
    
    val request = Request.Builder()
        .url("http://YOUR_SERVER_IP:5000/api/predict")
        .post(requestBody)
        .build()
    
    client.newCall(request).enqueue(object : Callback {
        override fun onResponse(call: Call, response: Response) {
            val json = response.body?.string()
            // Parse JSON response
        }
        
        override fun onFailure(call: Call, e: IOException) {
            // Handle error
        }
    })
}
```

### iOS (Swift)

```swift
func uploadImage(image: UIImage) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
    
    let url = URL(string: "http://YOUR_SERVER_IP:5000/api/predict")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", 
                     forHTTPHeaderField: "Content-Type")
    
    var data = Data()
    data.append("--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
    data.append(imageData)
    data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = data
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else { return }
        // Parse JSON response
    }.resume()
}
```

### React Native

```javascript
async function uploadImage(imageUri) {
  const formData = new FormData();
  formData.append('file', {
    uri: imageUri,
    name: 'image.jpg',
    type: 'image/jpeg'
  });
  formData.append('confidence_threshold', '0.25');
  
  try {
    const response = await fetch('http://YOUR_SERVER_IP:5000/api/predict', {
      method: 'POST',
      body: formData,
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    const result = await response.json();
    console.log(result);
  } catch (error) {
    console.error(error);
  }
}
```

---

## Production Deployment

### Option 1: Local Network

1. Find your local IP:
   ```bash
   ipconfig  # Windows
   ifconfig  # Mac/Linux
   ```

2. Update mobile app to use: `http://YOUR_LOCAL_IP:5000`

3. Ensure firewall allows port 5000

### Option 2: Cloud Deployment

**Recommended: Railway, Render, or AWS**

1. Create account on chosen platform
2. Upload this package
3. Set environment variables
4. Deploy
5. Update mobile app with deployed URL

### Option 3: Docker (Advanced)

Create `Dockerfile`:
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY . /app

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "api/api.py"]
```

Build and run:
```bash
docker build -t tooth-detection-api .
docker run -p 5000:5000 tooth-detection-api
```

## 🔧 Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: ModuleNotFoundError - No module named 'flask' (or other packages)

**Error:**
```
ModuleNotFoundError: No module named 'flask'
```

**Solution:**
Install the missing package:
```bash
pip install flask

# Or install all dependencies at once:
pip install flask flask-cors ultralytics pillow opencv-python reportlab google-generativeai python-dotenv pyyaml scikit-learn scipy tqdm werkzeug
```

#### Issue 2: PyTorch DLL Loading Error (Windows)

**Error:**
```
OSError: [WinError 1114] A dynamic link library (DLL) initialization routine failed.
Error loading "...\torch\lib\c10.dll" or one of its dependencies.
```

**Root Cause:** PyTorch 2.9.1+ has DLL compatibility issues on Windows

**Solution:**
Uninstall current PyTorch and install stable version 2.1.0:
```bash
# Uninstall problematic version
pip uninstall torch torchvision -y

# Install stable CPU version
pip install torch==2.1.0+cpu torchvision==0.16.0+cpu --index-url https://download.pytorch.org/whl/cpu
```

**Alternative Solution (if above doesn't work):**
Install Visual C++ Redistributables from Microsoft:
- Download: https://aka.ms/vs/17/release/vc_redist.x64.exe
- Run installer and restart computer

#### Issue 3: NumPy Version Incompatibility

**Error:**
```
A module that was compiled using NumPy 1.x cannot be run in NumPy 2.x
```

**Solution:**
Downgrade NumPy to compatible version:
```bash
pip install numpy==1.26.4
```

#### Issue 4: Model File Not Found

**Error:**
```
FileNotFoundError: Model not found at C:\...\model\best.pt
```

**Solution:**
1. Verify the model file exists:
   ```bash
   # Windows
   dir model\best.pt
   
   # macOS/Linux
   ls -lh model/best.pt
   ```

2. Check file size is ~49.6 MB

3. If missing, ensure you have the complete package with the model folder

#### Issue 5: Port 5000 Already in Use

**Error:**
```
OSError: [Errno 48] Address already in use
```

**Solution 1:** Stop the process using port 5000
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <process_id> /F

# macOS/Linux
lsof -ti:5000 | xargs kill -9
```

**Solution 2:** Change the port in `api/api.py`:
```python
# Line 152 in api.py
app.run(debug=True, host='0.0.0.0', port=8000)  # Changed from 5000
```

Then access at: `http://localhost:8000`

#### Issue 6: Import Error for 'reportlab'

**Error:**
```
ModuleNotFoundError: No module named 'reportlab'
```

**Solution:**
```bash
pip install reportlab
```

#### Issue 7: CORS Errors from Mobile App

**Error:**
```
Access to fetch at 'http://...' from origin '...' has been blocked by CORS policy
```

**Solution:**
CORS is already enabled in the API! If still having issues:

1. Ensure you're running the correct server
2. Check that `flask-cors` is installed:
   ```bash
   pip install flask-cors
   ```
3. Verify CORS is enabled in `api/api.py` (line 19):
   ```python
   CORS(app)
   ```

#### Issue 8: Large File Upload Fails

**Error:**
```
413 Request Entity Too Large
```

**Solution:**
Increase file size limit in `api/api.py`:
```python
# Line 26
MAX_FILE_SIZE = 32 * 1024 * 1024  # Increase to 32MB
```

#### Issue 9: Slow Prediction Times

**Symptoms:** Predictions take more than 5 seconds

**Solutions:**
1. **Use GPU version of PyTorch** (if you have NVIDIA GPU):
   ```bash
   pip uninstall torch torchvision -y
   pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
   ```

2. **Reduce image size before upload:**
   - Resize images to max 1024x1024 pixels
   - Compress JPEG quality to 80-90%

3. **Increase confidence threshold:**
   - Higher threshold = fewer detections = faster
   - Use 0.3-0.5 instead of 0.25

#### Issue 10: Gemini API Key Error

**Error:**
```
google.api_core.exceptions.PermissionDenied: 403 API key not valid
```

**Solution:**
1. Get a valid API key from: https://makersuite.google.com/app/apikey
2. Update `.env` file:
   ```
   GEMINI_API_KEY=your_valid_key_here
   ```
3. Restart the server

**Note:** API works without Gemini key, but AI insights won't be generated

#### Issue 11: Python Version Too Old

**Error:**
```
SyntaxError: invalid syntax
```

**Solution:**
Check Python version:
```bash
python --version
```

If less than 3.11, upgrade Python:
- Download from: https://www.python.org/downloads/
- Install and update PATH environment variable
- Restart terminal/command prompt

#### Issue 12: Permission Denied (Windows)

**Error:**
```
PermissionError: [WinError 5] Access is denied
```

**Solution:**
Run terminal as Administrator:
1. Right-click Command Prompt or PowerShell
2. Select "Run as Administrator"
3. Navigate to project directory and run commands

#### Issue 13: pip Not Recognized

**Error:**
```
'pip' is not recognized as an internal or external command
```

**Solution:**
1. Ensure Python is in PATH
2. Try using:
   ```bash
   python -m pip install <package_name>
   ```

3. Or reinstall Python with "Add to PATH" checked

#### Issue 14: Server Crashes on Prediction

**Symptoms:** Server stops when making prediction request

**Solutions:**
1. Check server logs for specific error
2. Verify image file is valid (not corrupted)
3. Try with smaller image (< 2MB)
4. Ensure sufficient RAM available (minimum 4GB recommended)
5. Check model file integrity:
   ```bash
   # Windows - should show ~49.6 MB
   dir model\best.pt
   ```

#### Issue 15: Firewall Blocking Access

**Symptoms:** Cannot access API from another device on network

**Solution (Windows):**
1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Click "Change settings"
4. Find Python and check both Private and Public boxes
5. Or temporarily disable firewall for testing

**Solution (macOS):**
```bash
# Allow Python through firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/python3
```

### Still Having Issues?

1. **Check Python version:** Must be 3.11+
   ```bash
   python --version
   ```

2. **Verify all packages installed:**
   ```bash
   pip list
   ```

3. **Check server logs:** Look at terminal output for error messages

4. **Test with minimal setup:**
   ```bash
   # Test PyTorch
   python -c "import torch; print('PyTorch OK:', torch.__version__)"
   
   # Test Flask
   python -c "import flask; print('Flask OK:', flask.__version__)"
   
   # Test Ultralytics
   python -c "import ultralytics; print('Ultralytics OK')"
   ```

5. **Clean reinstall:**
   ```bash
   # Uninstall all packages
   pip uninstall torch torchvision flask ultralytics -y
   
   # Follow installation steps from the beginning
   ```

6. **Check disk space:**
   - Ensure at least 2GB free space
   - Dependencies can be large

---

## Performance Specs

- **Model:** YOLOv8m
- **Accuracy:** 92.07% mAP@0.5
- **Classes:** 32 tooth numbers
- **Diseases:** 12 types (Healthy, Cavity, Calculus, etc.)
- **Processing Time:** 
  - CPU: ~1-2 seconds per image
  - GPU: ~0.2-0.5 seconds per image

---

## Support & Contact

For issues or questions:
1. Check troubleshooting section
2. Review API documentation
3. Test with provided frontend
4. Check server logs for errors

---

## License & Credits

- Model: YOLOv8 (Ultralytics)
- Framework: Flask
- PDF Generation: ReportLab
- Frontend: Vanilla HTML/CSS/JS

**Version:** 1.0  
**Last Updated:** November 2025  
**Model Trained:** 10 epochs, 92.07% mAP@0.5
