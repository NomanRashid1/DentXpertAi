"""
Enhanced Multi-Parameter Tooth Disease Prediction Script
Predicts: tooth number, disease type, severity, affected area, and confidence
Generates color-coded bounding boxes and comprehensive reports
"""

import os
import uuid
import csv
import json
import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageDraw, ImageFont
import cv2
import numpy as np
from ultralytics import YOLO
import google.generativeai as genai
from dotenv import load_dotenv
from pathlib import Path
from typing import List, Dict
from disease_classifier import DiseaseClassifier, DiseaseInfo, DiseaseType

# --- Configuration ---
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")  # Load from .env file
MODEL_PATH = "runs/train/multi_param_dental/weights/best.pt"  # Updated model path

OUTPUT_DIR = "results_pridects"
CSV_REPORT_PATH = os.path.join(OUTPUT_DIR, "report.csv")
JSON_REPORT_PATH = os.path.join(OUTPUT_DIR, "report.json")


class ToothDiseasePredictor:
    """Multi-parameter tooth disease prediction system"""
    
    def __init__(self, model_path: str = None, gemini_api_key: str = None):
        """Initialize predictor with model and optional Gemini AI"""
        # Calculate default model path if not provided
        if model_path is None:
            model_path = str(Path(__file__).parent.parent / "model" / "best.pt")
        
        self.model_path = model_path
        self.model = None
        self.gemini_model = None
        
        # Load YOLO model
        self.load_model()
        
        # Initialize Gemini if API key provided
        if gemini_api_key:
            self.initialize_gemini(gemini_api_key)
        
        # Create output directory
        os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    def load_model(self):
        """Load the trained YOLO model"""
        try:
            if not os.path.exists(self.model_path):
                raise FileNotFoundError(f"Model not found at {self.model_path}")
            
            self.model = YOLO(self.model_path)
            print(f"✅ Model loaded from: {self.model_path}")
            print(f"   Classes: {len(self.model.names)} - {list(self.model.names.values())}")
        except Exception as e:
            print(f"❌ Failed to load model: {e}")
            print("   Please train the model first using: python train.py")
            raise
    
    def initialize_gemini(self, api_key: str):
        """Initialize Gemini AI for report generation"""
        try:
            genai.configure(api_key=api_key)
            self.gemini_model = genai.GenerativeModel('gemini-2.0-flash-exp')
            print("✅ Gemini AI initialized")
        except Exception as e:
            print(f"⚠️ Gemini AI initialization failed: {e}")
            self.gemini_model = None
    
    def predict(self, image_path: str, conf_threshold: float = 0.25) -> Dict:
        """
        Predict tooth diseases in X-ray image
        
        Args:
            image_path: Path to X-ray image
            conf_threshold: Confidence threshold for detections
            
        Returns:
            Dictionary with all prediction results and summary statistics
        """
        print(f"\n🔍 Analyzing: {os.path.basename(image_path)}")
        
        # Run YOLO model
        results = self.model(image_path, conf=conf_threshold, verbose=False)
        
        # Process detections
        detections = self.process_detections(results, image_path)
        
        # Generate unique ID
        unique_id = str(uuid.uuid4())
        
        # Create annotated image with non-overlapping labels
        output_image = self.create_annotated_image(image_path, detections, unique_id)
        
        # Generate report
        report = self.generate_report(detections, image_path)
        
        # Calculate summary statistics
        disease_distribution = {}
        severity_distribution = {}
        
        for det in detections:
            disease = det['disease_type']
            severity = det['severity']
            
            disease_distribution[disease] = disease_distribution.get(disease, 0) + 1
            severity_distribution[severity] = severity_distribution.get(severity, 0) + 1
        
        # Prepare complete results
        prediction_results = {
            'unique_id': unique_id,
            'input_image': image_path,
            'output_image': output_image,
            'total_detections': len(detections),
            'detections': detections,
            'report': report,
            'summary': {
                'total_teeth': len(detections),
                'disease_distribution': disease_distribution,
                'severity_distribution': severity_distribution,
                'healthy_teeth': disease_distribution.get('Healthy', 0),
                'diseased_teeth': sum(v for k, v in disease_distribution.items() if k != 'Healthy')
            }
        }
        
        # Save reports
        self.save_reports(prediction_results)
        
        return prediction_results
    
    def process_detections(self, results, image_path: str) -> List[Dict]:
        """Process YOLO detections and extract segmentation masks or create polygon approximations"""
        detections = []
        
        # Load image for OpenCV processing
        cv_image = cv2.imread(image_path)
        if cv_image is None:
            print(f"⚠️ Could not load image for contour extraction: {image_path}")
        
        for r in results:
            if not r.boxes:
                continue
            
            # Check if model outputs segmentation masks
            has_masks = hasattr(r, 'masks') and r.masks is not None
            
            for idx, box in enumerate(r.boxes):
                # Extract YOLO outputs
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                conf = float(box.conf[0])
                cls = int(box.cls[0])
                class_name = self.model.names[cls]
                
                # Parse tooth number from class name (assumes format "13", "14", etc.)
                try:
                    tooth_number = int(class_name)
                except:
                    tooth_number = 0  # Unknown tooth number
                
                # Classify disease
                disease_info = DiseaseClassifier.classify_from_model_output(
                    class_name=f"tooth_{class_name}",
                    confidence=conf,
                    tooth_number=tooth_number
                )
                
                # Get tooth name
                tooth_name = DiseaseClassifier.get_tooth_name(tooth_number)
                
                # Extract or create polygon for segmentation visualization
                polygon = None
                if has_masks:
                    try:
                        # Extract segmentation mask polygon
                        mask = r.masks.xy[idx]
                        if len(mask) > 0:
                            polygon = [(int(x), int(y)) for x, y in mask]
                    except:
                        pass
                
                # If no mask available, use smart contour extraction
                if polygon is None:
                    polygon = self._extract_tooth_contour(cv_image, x1, y1, x2, y2)
                
                # Assign color based on tooth number for consistent rainbow scheme
                # Colors from reference: Green, Yellow, Cyan, Purple, Blue, Orange, Pink, Red
                rainbow_colors = [
                    '#00FF00', # Green
                    '#FFFF00', # Yellow
                    '#00FFFF', # Cyan
                    '#800080', # Purple
                    '#0000FF', # Blue
                    '#FFA500', # Orange
                    '#FF00FF', # Magenta
                    '#FF0000', # Red
                    '#008080', # Teal
                    '#FFC0CB', # Pink
                ]
                color_idx = (tooth_number % len(rainbow_colors))
                fixed_color = rainbow_colors[color_idx]

                # Compile detection
                detection = {
                    "tooth_number": tooth_number,
                    "tooth_name": tooth_name,
                    "disease_type": disease_info.disease_type.value,
                    "severity": disease_info.severity.value,
                    "affected_area": disease_info.affected_area.value,
                    "confidence": conf,
                    "bounding_box": {
                        "x1": x1, "y1": y1,
                        "x2": x2, "y2": y2
                    },
                    "polygon": polygon,  # Add polygon coordinates
                    "color": fixed_color, # Use fixed rainbow color
                    "recommendations": disease_info.recommendations[:3],
                    "urgency": DiseaseClassifier.get_urgency_level(
                        disease_info.disease_type, disease_info.severity
                    )
                }
                
                detections.append(detection)
        
        # Sort by tooth number
        detections.sort(key=lambda x: x['tooth_number'])
        
        return detections
    
    def _extract_tooth_contour(self, image, x1, y1, x2, y2) -> List[tuple]:
        """
        Extract precise tooth contour using GrabCut algorithm for organic shapes
        Returns a polygon list of (x, y) tuples
        """
        if image is None:
            return self._create_tooth_polygon(x1, y1, x2, y2)

        try:
            # 1. Crop the bounding box area with padding
            h, w = image.shape[:2]
            pad = 5
            x1_pad = max(0, x1 - pad)
            y1_pad = max(0, y1 - pad)
            x2_pad = min(w, x2 + pad)
            y2_pad = min(h, y2 + pad)
            
            roi = image[y1_pad:y2_pad, x1_pad:x2_pad]
            if roi.size == 0:
                return self._create_tooth_polygon(x1, y1, x2, y2)

            # 2. Initialize GrabCut mask and models
            mask = np.zeros(roi.shape[:2], np.uint8)
            bgdModel = np.zeros((1, 65), np.float64)
            fgdModel = np.zeros((1, 65), np.float64)

            # 3. Define rectangle for GrabCut (relative to ROI)
            # We assume the tooth is centered in the box, so we take a slightly smaller rect
            roi_h, roi_w = roi.shape[:2]
            rect = (pad, pad, roi_w - 2*pad, roi_h - 2*pad)
            
            # 4. Run GrabCut
            # iterCount=5 gives good balance of speed/quality
            cv2.grabCut(roi, mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT)

            # 5. Create binary mask (pixels 1 and 3 are foreground/probable foreground)
            mask2 = np.where((mask == 2) | (mask == 0), 0, 1).astype('uint8')

            # 6. Smooth the mask
            # Apply morphological closing to fill small holes
            kernel = np.ones((5, 5), np.uint8)
            mask2 = cv2.morphologyEx(mask2, cv2.MORPH_CLOSE, kernel)
            # Apply Gaussian blur to smooth edges
            mask2 = cv2.GaussianBlur(mask2 * 255, (9, 9), 0)
            _, mask2 = cv2.threshold(mask2, 127, 255, cv2.THRESH_BINARY)

            # 7. Find contours
            contours, _ = cv2.findContours(mask2, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            if not contours:
                return self._create_tooth_polygon(x1, y1, x2, y2)

            # 8. Find the largest contour
            largest_contour = max(contours, key=cv2.contourArea)

            # 9. Smooth the contour (approxPolyDP)
            # Use smaller epsilon for more organic shape (0.002 instead of 0.005)
            epsilon = 0.002 * cv2.arcLength(largest_contour, True)
            approx_contour = cv2.approxPolyDP(largest_contour, epsilon, True)

            # 10. Convert to global coordinates
            polygon = []
            for point in approx_contour:
                px, py = point[0]
                polygon.append((int(x1_pad + px), int(y1_pad + py)))

            # Ensure polygon is valid
            if len(polygon) < 3:
                return self._create_tooth_polygon(x1, y1, x2, y2)

            return polygon

        except Exception as e:
            print(f"Error extracting contour: {e}")
            return self._create_tooth_polygon(x1, y1, x2, y2)

    def _create_tooth_polygon(self, x1: int, y1: int, x2: int, y2: int) -> List[tuple]:
        """Create a tooth-shaped polygon from bounding box coordinates"""
        # Calculate dimensions
        width = x2 - x1
        height = y2 - y1
        
        # Create a tooth-like polygon (crown + root shape)
        crown_height = int(height * 0.6)  # Crown is top 60%
        
        polygon = [
            # Crown top (rounded)
            (x1 + width // 4, y1),
            (x1 + 3 * width // 4, y1),
            (x2, y1 + crown_height // 3),
            (x2, y1 + crown_height),
            # Root (tapers down)
            (x1 + 3 * width // 4, y1 + height),
            (x1 + width // 4, y1 + height),
            (x1, y1 + crown_height),
            (x1, y1 + crown_height // 3),
        ]
        
        return polygon
    
    def create_annotated_image(self, image_path: str, detections: List[Dict], unique_id: str) -> str:
        """Create image with color-coded polygon segmentation masks and non-overlapping labels"""
        import random
        
        # Load image
        original_image = Image.open(image_path)
        annotated_image = original_image.copy()
        draw = ImageDraw.Draw(annotated_image)
        
        # Load font
        try:
            font_large = ImageFont.truetype("arial.ttf", 20)
            font_small = ImageFont.truetype("arial.ttf", 16)
        except IOError:
            font_large = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        
        # Track label positions to avoid overlaps
        used_label_positions = []
        
        # Filter: Only show diseased teeth (skip healthy ones)
        diseased_detections = [
            (idx, det) for idx, det in enumerate(detections) 
            if det['disease_type'].lower() != 'healthy'
        ]
        
        # Create a semi-transparent overlay for bright colored fills
        overlay = Image.new('RGBA', annotated_image.size, (0, 0, 0, 0))
        overlay_draw = ImageDraw.Draw(overlay)
        
        # Draw each diseased tooth detection
        for idx, detection in diseased_detections:
            bbox = detection['bounding_box']
            x1, y1, x2, y2 = bbox['x1'], bbox['y1'], bbox['x2'], bbox['y2']
            polygon = detection.get('polygon', [])
            color_hex = detection.get('color', '#FFFFFF') # Use the fixed color assigned earlier
            
            # Convert hex color to RGB
            color_rgb = tuple(int(color_hex.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))
            
            # Draw filled polygon with semi-transparency (bright colors)
            if polygon and len(polygon) >= 3:
                # Create semi-transparent fill color (50% opacity for brightness)
                fill_color = color_rgb + (128,)  # 128 = 50% of 255
                overlay_draw.polygon(polygon, fill=fill_color)
                
                # Draw thin colored outline for definition
                draw.polygon(polygon, outline=color_hex, width=2)
            
            # Prepare label texts
            disease_text = detection['disease_type']
            tooth_text = f"#{detection['tooth_number']}"
            conf_text = f"{detection['confidence']:.0%}"
            
            # Combine into single line for space efficiency
            label_text = f"{disease_text} {tooth_text} ({conf_text})"
            
            # Calculate text size
            text_bbox = draw.textbbox((0, 0), label_text, font=font_small)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]
            
            # Smart label positioning to avoid overlaps
            label_y = y1 - text_height - 8  # Start above the box
            label_x = x1
            
            # Check for overlap with existing labels and adjust
            max_attempts = 10
            attempt = 0
            while attempt < max_attempts:
                overlap = False
                for used_pos in used_label_positions:
                    used_x, used_y, used_w, used_h = used_pos
                    # Check if labels overlap
                    if not (label_x + text_width < used_x or 
                           label_x > used_x + used_w or
                           label_y + text_height < used_y or 
                           label_y > used_y + used_h):
                        overlap = True
                        break
                
                if not overlap:
                    break
                
                # Try different positions
                if attempt == 0:
                    label_y = y2 + 5  # Below the box
                elif attempt == 1:
                    label_x = x2 - text_width  # Right-aligned above
                elif attempt == 2:
                    label_y = y1 + (y2 - y1) // 2  # Middle of box
                    label_x = x2 + 5  # Right side
                elif attempt == 3:
                    label_x = x1 - text_width - 5  # Left side
                else:
                    # Random offset
                    label_y += random.randint(-20, 20)
                    label_x += random.randint(-10, 10)
                
                # Keep in bounds
                label_x = max(0, min(label_x, original_image.width - text_width))
                label_y = max(0, min(label_y, original_image.height - text_height))
                
                attempt += 1
            
            # Record this label position
            used_label_positions.append((label_x, label_y, text_width, text_height))
            
            # Draw label background (semi-transparent effect with padding)
            padding = 4
            bg_bbox = [
                label_x - padding,
                label_y - padding,
                label_x + text_width + padding,
                label_y + text_height + padding
            ]
            
            # Draw black background for contrast
            draw.rectangle(bg_bbox, fill="black")
            
            # Draw colored border around label
            draw.rectangle(bg_bbox, outline=color_hex, width=2)
            
            # Draw white text
            draw.text((label_x, label_y), label_text, fill="white", font=font_small)
        
        # Composite the overlay with filled polygons onto the original image
        annotated_image = annotated_image.convert('RGBA')
        annotated_image = Image.alpha_composite(annotated_image, overlay)
        annotated_image = annotated_image.convert('RGB')
        
        # Save annotated image
        output_path = os.path.join(OUTPUT_DIR, f"{unique_id}.jpg")
        annotated_image.save(output_path, quality=95)
        print(f"✅ Annotated image saved: {output_path}")
        
        return output_path
    
    def create_summary(self, detections: List[Dict]) -> Dict:
        """Create statistical summary of detections"""
        if not detections:
            return {"message": "No teeth detected"}
        
        # Count disease types
        disease_counts = {}
        severity_counts = {}
        urgency_counts = {}
        
        for det in detections:
            disease = det['disease_type']
            severity = det['severity']
            urgency = det['urgency'].split(' - ')[0]  # Extract urgency level
            
            disease_counts[disease] = disease_counts.get(disease, 0) + 1
            severity_counts[severity] = severity_counts.get(severity, 0) + 1
            urgency_counts[urgency] = urgency_counts.get(urgency, 0) + 1
        
        return {
            "total_teeth": len(detections),
            "disease_distribution": disease_counts,
            "severity_distribution": severity_counts,
            "urgency_distribution": urgency_counts,
            "tooth_numbers": [d['tooth_number'] for d in detections]
        }
    
    def generate_report(self, detections: List[Dict], image_path: str) -> str:
        """Generate comprehensive text report"""
        if not detections:
            return "No dental abnormalities detected in the X-ray image."
        
        # Build detailed report
        report_lines = []
        report_lines.append("=" * 80)
        report_lines.append("DENTAL X-RAY ANALYSIS REPORT")
        report_lines.append("=" * 80)
        report_lines.append(f"\nImage: {os.path.basename(image_path)}")
        report_lines.append(f"Total Teeth Detected: {len(detections)}\n")
        
        # Group by urgency
        urgent = [d for d in detections if "URGENT" in d['urgency'] or "HIGH" in d['urgency']]
        non_urgent = [d for d in detections if d not in urgent]
        
        if urgent:
            report_lines.append("\n⚠️  URGENT/HIGH PRIORITY FINDINGS:")
            report_lines.append("-" * 80)
            for det in urgent:
                report_lines.append(f"\n🦷 {det['tooth_name']} (#{det['tooth_number']})")
                report_lines.append(f"   Disease: {det['disease_type']}")
                report_lines.append(f"   Severity: {det['severity']}")
                report_lines.append(f"   Affected Area: {det['affected_area']}")
                report_lines.append(f"   Confidence: {det['confidence']:.2%}")
                report_lines.append(f"   Urgency: {det['urgency']}")
                report_lines.append(f"   Recommendations:")
                for rec in det['recommendations']:
                    report_lines.append(f"      • {rec}")
        
        if non_urgent:
            report_lines.append("\n\n📋 OTHER FINDINGS:")
            report_lines.append("-" * 80)
            for det in non_urgent:
                report_lines.append(f"\n🦷 {det['tooth_name']} (#{det['tooth_number']})")
                report_lines.append(f"   Status: {det['disease_type']} ({det['severity']})")
                report_lines.append(f"   Confidence: {det['confidence']:.2%}")
        
        # Add AI-generated insights if available
        if self.gemini_model:
            report_lines.append("\n\n💡 AI-GENERATED INSIGHTS:")
            report_lines.append("-" * 80)
            ai_insights = self.get_ai_insights(detections)
            report_lines.append(ai_insights)
        
        report_lines.append("\n" + "=" * 80)
        report_lines.append("END OF REPORT")
        report_lines.append("=" * 80)
        
        return "\n".join(report_lines)
    
    def get_ai_insights(self, detections: List[Dict]) -> str:
        """Get AI-generated insights using Gemini"""
        if not self.gemini_model:
            return "AI insights not available (no API key provided)"
        
        # Build prompt
        prompt = "Based on the following dental X-ray analysis, provide professional insights and recommendations:\n\n"
        
        for det in detections:
            prompt += f"- Tooth #{det['tooth_number']}: {det['disease_type']} ({det['severity']})\n"
        
        prompt += "\nPlease provide:\n"
        prompt += "1. Overall oral health assessment\n"
        prompt += "2. Priority treatment recommendations\n"
        prompt += "3. Preventive care suggestions\n"
        prompt += "Keep the response concise and professional."
        
        try:
            response = self.gemini_model.generate_content(prompt)
            return response.text
        except Exception as e:
            return f"Error generating AI insights: {e}"
    
    def save_reports(self, results: Dict):
        """Save reports in multiple formats"""
        unique_id = results['unique_id']
        
        # 1. CSV Report (append mode for batch processing)
        csv_exists = os.path.exists(CSV_REPORT_PATH)
        with open(CSV_REPORT_PATH, mode='a', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            if not csv_exists:
                writer.writerow([
                    "unique_id", "input_image", "output_image", "total_detections",
                    "tooth_numbers", "diseases", "report_summary"
                ])
            
            tooth_nums = ', '.join([str(d['tooth_number']) for d in results['detections']])
            diseases = ', '.join([d['disease_type'] for d in results['detections']])
            
            writer.writerow([
                unique_id,
                results['input_image'],
                results['output_image'],
                results['total_detections'],
                tooth_nums,
                diseases,
                str(results['summary'])
            ])
        
        print(f"✅ CSV report updated: {CSV_REPORT_PATH}")
        
        # 2. JSON Report (detailed)
        json_output_path = os.path.join(OUTPUT_DIR, f"{unique_id}.json")
        with open(json_output_path, 'w', encoding='utf-8') as f:
            json.dump(results, f, indent=2, ensure_ascii=False)
        
        print(f"✅ JSON report saved: {json_output_path}")
        
        # 3. Text Report
        txt_output_path = os.path.join(OUTPUT_DIR, f"{unique_id}.txt")
        with open(txt_output_path, 'w', encoding='utf-8') as f:
            f.write(results['report'])
        
        print(f"✅ Text report saved: {txt_output_path}")


def main():
    """Main execution function with file selection dialog"""
    print("\n" + "=" * 80)
    print("MULTI-PARAMETER TOOTH DISEASE DETECTION - PREDICTION")
    print("=" * 80 + "\n")
    
    # Check if model exists
    if not os.path.exists(MODEL_PATH):
        print(f"❌ Model not found at: {MODEL_PATH}")
        print("   Please train the model first: python train.py")
        return
    
    # Create file selection dialog
    root = tk.Tk()
    root.withdraw()
    
    image_path = filedialog.askopenfilename(
        title="Select Dental X-Ray Image",
        filetypes=[
            ("Image Files", "*.jpg *.jpeg *.png *.bmp"),
            ("All Files", "*.*")
        ]
    )
    
    if not image_path:
        print("❌ No image selected. Exiting.")
        return
    
    # Initialize predictor
    predictor = ToothDiseasePredictor(
        model_path=MODEL_PATH,
        gemini_api_key=GEMINI_API_KEY if GEMINI_API_KEY else None
    )
    
    # Run prediction
    results = predictor.predict(image_path, conf_threshold=0.25)
    
    # Print summary
    print("\n" + "=" * 80)
    print("PREDICTION SUMMARY")
    print("=" * 80)
    print(f"\n📊 Total teeth detected: {results['total_detections']}")
    
    if results['detections']:
        print(f"\n🦷 Detected teeth:")
        for det in results['detections']:
            print(f"   • Tooth #{det['tooth_number']}: {det['disease_type']} "
                  f"({det['severity']}) - {det['confidence']:.1%} confidence")
    
    print(f"\n📁 Results saved to: {OUTPUT_DIR}")
    print(f"   • Annotated image: {results['output_image']}")
    print(f"   • CSV report: {CSV_REPORT_PATH}")
    print(f"   • Detailed reports: {OUTPUT_DIR}/{results['unique_id']}.*")
    
    print("\n✅ Prediction complete!\n")


if __name__ == "__main__":
    main()
