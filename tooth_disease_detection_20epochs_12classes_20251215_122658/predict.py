import os
import uuid
import csv
import tkinter as tk
from tkinter import filedialog
from PIL import Image, ImageDraw, ImageFont
from ultralytics import YOLO
import google.generativeai as genai
from dotenv import load_dotenv
import random

# --- Configuration ---
load_dotenv()
GEMINI_API_KEY = os.getenv("AIzaSyAxe67-TNNbLiwIDVGQ3CPqyDfgV0TF4hc")
MODEL_PATH = r"D:\final year project\runs\train\dental_detection\weights\best.pt"

OUTPUT_DIR = "results_pridects"
CSV_REPORT_PATH = os.path.join(OUTPUT_DIR, "report.csv")

def initialize_gemini():
    """Initializes the Gemini API."""
    try:
        genai.configure(api_key=GEMINI_API_KEY)
        return genai.GenerativeModel('gemini-2.0-flash')
    except Exception as e:
        print(f"Error initializing Gemini: {e}")
        return None

def create_output_directory():
    """Creates the output directory if it doesn't exist."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)

def generate_unique_id():
    """Generates a unique ID for the prediction."""
    return str(uuid.uuid4())

def update_csv_report(unique_id, report_text):
    """Appends a new record to the CSV report."""
    file_exists = os.path.isfile(CSV_REPORT_PATH)
    with open(CSV_REPORT_PATH, mode='a', newline='', encoding='utf-8') as csv_file:
        writer = csv.writer(csv_file)
        if not file_exists:
            writer.writerow(["unique_id", "report"])
        writer.writerow([unique_id, report_text])

def predict_and_save(image_path, model, gemini_model):
    """
    Runs prediction on an image, saves the result with colored overlays, and generates a report.
    """
    if not os.path.exists(image_path):
        print(f"Error: Image path not found at {image_path}")
        return

    try:
        # --- Prediction ---
        results = model(image_path)
        
        # Load image and ensure RGB mode (important for grayscale X-rays)
        original_image = Image.open(image_path)
        if original_image.mode != 'RGB':
            original_image = original_image.convert('RGB')
        original_image = original_image.convert('RGBA')
        
        # Create overlay layer for semi-transparent colored regions
        overlay = Image.new('RGBA', original_image.size, (0, 0, 0, 0))
        overlay_draw = ImageDraw.Draw(overlay)
        
        try:
            font = ImageFont.truetype("arial.ttf", 20)
        except IOError:
            font = ImageFont.load_default()

        gemini_prompt_details = []
        detections_count = 0

        # Draw colored overlays
        for r in results:
            if r.boxes:
                detections_count += len(r.boxes)
                for box in r.boxes:
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    conf = box.conf[0]
                    cls = int(box.cls[0])
                    class_name = model.names[cls]

                    # Create semi-transparent colored overlay (65% opacity for better visibility)
                    random.seed(cls)  # Consistent color per class
                    r_val = random.randint(100, 255)
                    g_val = random.randint(100, 255)
                    b_val = random.randint(100, 255)
                    overlay_color = (r_val, g_val, b_val, 165)  # 165 = 65% opacity
                    
                    # Draw filled rectangle on overlay
                    overlay_draw.rectangle([x1, y1, x2, y2], fill=overlay_color)
                    
                    # Draw colored border (thicker and more opaque)
                    border_color = (r_val, g_val, b_val, 220)
                    for i in range(3):
                        overlay_draw.rectangle(
                            [x1 + i, y1 + i, x2 - i, y2 - i], 
                            outline=border_color, 
                            width=1
                        )

                    gemini_prompt_details.append(f"  - Class: {class_name}, Confidence: {conf:.2f}, Bounding Box: ({x1}, {y1}, {x2}, {y2})")

        # Composite the overlay onto the original image
        processed_image = Image.alpha_composite(original_image, overlay)
        processed_image = processed_image.convert('RGB')
        draw = ImageDraw.Draw(processed_image)
        
        # Draw labels
        for r in results:
            if r.boxes:
                for box in r.boxes:
                    x1, y1, x2, y2 = map(int, box.xyxy[0])
                    conf = box.conf[0]
                    cls = int(box.cls[0])
                    class_name = model.names[cls]
                    
                    # Generate same color for label
                    random.seed(cls)
                    r_val = random.randint(100, 255)
                    g_val = random.randint(100, 255)
                    b_val = random.randint(100, 255)
                    color_hex = f"#{r_val:02x}{g_val:02x}{b_val:02x}"
                    
                    # Draw label
                    label_text = f"{class_name} {conf:.2f}"
                    text_bbox = draw.textbbox((x1, y1 - 25), label_text, font=font)
                    draw.rectangle(text_bbox, fill="black")
                    draw.rectangle(text_bbox, outline=color_hex, width=2)
                    draw.text((x1, y1 - 25), label_text, fill="white", font=font)

        # --- Save Processed Image ---
        unique_id = generate_unique_id()
        output_image_path = os.path.join(OUTPUT_DIR, f"{unique_id}.jpg")
        processed_image.save(output_image_path)
        print(f"Processed image saved to: {output_image_path}")

        # --- Generate Report with Gemini ---
        if detections_count == 0:
            gemini_prompt = "No dental diseases were detected in the image."
        else:
            gemini_prompt = f"Based on the image analysis, the following dental diseases/conditions were detected:\n" \
                            f"\n".join(gemini_prompt_details) + \
                            f"\n\nPlease generate a concise and informative report summarizing these findings, suitable for a dental professional or patient. Focus on clarity and actionable insights if possible."

        if gemini_model:
            try:
                gemini_response = gemini_model.generate_content(gemini_prompt)
                report_text = gemini_response.text
            except Exception as e:
                print(f"Error generating Gemini report: {e}")
                report_text = f"Could not generate a detailed report. Using basic detection info.\nBased on the image analysis, the following dental diseases/conditions were detected:\n" + "\n".join(gemini_prompt_details)
        else:
            report_text = f"Gemini model not initialized. Using basic detection info.\nBased on the image analysis, the following dental diseases/conditions were detected:\n" + "\n".join(gemini_prompt_details)

        # --- Update CSV Report ---
        update_csv_report(unique_id, report_text)
        print(f"Report for {unique_id} added to {CSV_REPORT_PATH}")

    except Exception as e:
        print(f"An error occurred during prediction: {e}")

def main():
    root = tk.Tk()
    root.withdraw()  # Hide the main window

    image_path = filedialog.askopenfilename(
        title="Select Image File",
        filetypes=[("Image Files", "*.jpg *.jpeg *.png *.bmp *.gif")]
    )

    if not image_path:
        print("No image selected. Exiting.")
        return

    create_output_directory()
    
    try:
        model = YOLO(MODEL_PATH)
    except Exception as e:
        print(f"Failed to load model: {e}")
        return

    gemini_model = initialize_gemini()
    
    predict_and_save(image_path, model, gemini_model)

if __name__ == "__main__":
    main()