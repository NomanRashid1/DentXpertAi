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

## Quick Start Guide

### 1. Install Python 3.11+

Download from: https://www.python.org/downloads/

### 2. Install Dependencies

```bash
cd Tooth_Detection_API_Package
pip install -r requirements.txt
```

### 3. Configure Environment (Optional)

For AI-powered insights, create a `.env` file:
```
GEMINI_API_KEY=your_api_key_here
```

### 4. Start API Server

```bash
cd api
python api.py
```

Server will start at: `http://localhost:5000`

### 5. Test API

Open browser: `http://localhost:5000/api/health`

Or test with frontend: Open `frontend/index.html`

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

---

## Troubleshooting

### Issue: Model not loading

**Solution:** Ensure `model/best.pt` exists and is 49.6 MB

### Issue: Port 5000 already in use

**Solution:** Change port in `api/api.py`:
```python
app.run(debug=True, host='0.0.0.0', port=8000)  # Changed from 5000
```

### Issue: CORS errors from mobile app

**Solution:** Already configured! CORS is enabled for all origins.

### Issue: Large file uploads fail

**Solution:** Increase `MAX_FILE_SIZE` in `api/api.py`

### Issue: Slow predictions

**Solution:** 
- Use GPU if available
- Reduce image size before uploading
- Lower confidence threshold filters fewer detections

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
