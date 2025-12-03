"""
PDF Report Generator for Tooth Disease Detection
Generates professional PDF reports with annotated images and all parameters
"""

from reportlab.lib.pagesizes import letter, A4
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer, Image, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from reportlab.pdfgen import canvas
from datetime import datetime
import os


class PDFReportGenerator:
    """Generate comprehensive PDF reports for dental X-ray analysis"""
    
    def __init__(self, output_dir="results_pridects"):
        self.output_dir = output_dir
        self.styles = getSampleStyleSheet()
        self._setup_custom_styles()
    
    def _setup_custom_styles(self):
        """Setup custom paragraph styles"""
        # Title style
        self.title_style = ParagraphStyle(
            'CustomTitle',
            parent=self.styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#2C3E50'),
            spaceAfter=30,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold'
        )
        
        # Heading style
        self.heading_style = ParagraphStyle(
            'CustomHeading',
            parent=self.styles['Heading2'],
            fontSize=16,
            textColor=colors.HexColor('#34495E'),
            spaceAfter=12,
            spaceBefore=12,
            fontName='Helvetica-Bold'
        )
        
        # Body style
        self.body_style = ParagraphStyle(
            'CustomBody',
            parent=self.styles['BodyText'],
            fontSize=11,
            spaceAfter=6,
            fontName='Helvetica'
        )
        
        # Small text style
        self.small_style = ParagraphStyle(
            'SmallText',
            parent=self.styles['BodyText'],
            fontSize=9,
            textColor=colors.HexColor('#7F8C8D'),
            fontName='Helvetica'
        )
    
    def generate_report(self, prediction_results: dict, output_filename: str = None) -> str:
        """
        Generate comprehensive PDF report
        
        Args:
            prediction_results: Dictionary with prediction results
            output_filename: Optional custom filename
            
        Returns:
            Path to generated PDF file
        """
        if output_filename is None:
            output_filename = f"report_{prediction_results['unique_id']}.pdf"
        
        pdf_path = os.path.join(self.output_dir, output_filename)
        
        # Create PDF document
        doc = SimpleDocTemplate(
            pdf_path,
            pagesize=letter,
            rightMargin=0.75*inch,
            leftMargin=0.75*inch,
            topMargin=1*inch,
            bottomMargin=0.75*inch
        )
        
        # Build content
        story = []
        
        # Add header
        story.extend(self._create_header(prediction_results))
        
        # Add summary section
        story.extend(self._create_summary_section(prediction_results))
        
        # Add annotated image
        story.extend(self._create_image_section(prediction_results))
        
        # Add detailed findings
        story.extend(self._create_detailed_findings(prediction_results))
        
        # Add recommendations
        story.extend(self._create_recommendations(prediction_results))
        
        # Add footer info
        story.extend(self._create_footer())
        
        # Build PDF
        doc.build(story)
        
        return pdf_path
    
    def _create_header(self, results: dict):
        """Create report header"""
        elements = []
        
        # Title
        title = Paragraph("DENTAL X-RAY ANALYSIS REPORT", self.title_style)
        elements.append(title)
        elements.append(Spacer(1, 0.2*inch))
        
        # Report info table
        report_data = [
            ['Report ID:', results['unique_id'][:18]],
            ['Date Generated:', datetime.now().strftime('%Y-%m-%d %H:%M:%S')],
            ['Image:', os.path.basename(results.get('input_image', 'N/A'))],
            ['Total Detections:', str(results['total_detections'])]
        ]
        
        report_table = Table(report_data, colWidths=[2*inch, 4*inch])
        report_table.setStyle(TableStyle([
            ('FONT', (0, 0), (-1, -1), 'Helvetica', 10),
            ('FONT', (0, 0), (0, -1), 'Helvetica-Bold', 10),
            ('TEXTCOLOR', (0, 0), (0, -1), colors.HexColor('#2C3E50')),
            ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
            ('ALIGN', (1, 0), (1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ]))
        
        elements.append(report_table)
        elements.append(Spacer(1, 0.3*inch))
        
        return elements
    
    def _create_summary_section(self, results: dict):
        """Create summary statistics section"""
        elements = []
        
        # Section heading
        heading = Paragraph("OVERVIEW", self.heading_style)
        elements.append(heading)
        
        summary = results.get('summary', {})
        
        # Summary table
        summary_data = [
            ['Total Teeth Detected', str(summary.get('total_teeth', 0))],
        ]
        
        # Disease distribution
        disease_dist = summary.get('disease_distribution', {})
        if disease_dist:
            summary_data.append(['Disease Distribution', ''])
            for disease, count in sorted(disease_dist.items(), key=lambda x: x[1], reverse=True):
                summary_data.append(['  • ' + disease, str(count)])
        
        # Severity distribution
        severity_dist = summary.get('severity_distribution', {})
        if severity_dist:
            summary_data.append(['Severity Distribution', ''])
            for severity, count in sorted(severity_dist.items(), key=lambda x: x[1], reverse=True):
                summary_data.append(['  • ' + severity, str(count)])
        
        summary_table = Table(summary_data, colWidths=[4*inch, 2*inch])
        summary_table.setStyle(TableStyle([
            ('FONT', (0, 0), (-1, -1), 'Helvetica', 10),
            ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
            ('ALIGN', (1, 0), (1, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            ('LINEABOVE', (0, 0), (-1, 0), 1, colors.HexColor('#BDC3C7')),
            ('LINEBELOW', (0, -1), (-1, -1), 1, colors.HexColor('#BDC3C7')),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ]))
        
        elements.append(summary_table)
        elements.append(Spacer(1, 0.3*inch))
        
        return elements
    
    def _create_image_section(self, results: dict):
        """Add annotated X-ray image"""
        elements = []
        
        # Section heading
        heading = Paragraph("ANNOTATED X-RAY IMAGE", self.heading_style)
        elements.append(heading)
        
        # Add image
        image_path = results.get('output_image')
        if image_path and os.path.exists(image_path):
            try:
                # Scale image to fit page width
                img = Image(image_path, width=6.5*inch, height=4*inch, kind='proportional')
                elements.append(img)
            except Exception as e:
                elements.append(Paragraph(f"Error loading image: {e}", self.body_style))
        else:
            elements.append(Paragraph("Annotated image not available", self.body_style))
        
        elements.append(Spacer(1, 0.3*inch))
        
        return elements
    
    def _create_detailed_findings(self, results: dict):
        """Create detailed findings table"""
        elements = []
        
        # Section heading
        heading = Paragraph("DETAILED FINDINGS", self.heading_style)
        elements.append(heading)
        
        detections = results.get('detections', [])
        
        if not detections:
            elements.append(Paragraph("No abnormalities detected.", self.body_style))
            return elements
        
        # Create table data
        table_data = [
            ['<b>Tooth #</b>', '<b>Disease</b>', '<b>Severity</b>', '<b>Area</b>', '<b>Confidence</b>', '<b>Urgency</b>']
        ]
        
        for det in detections:
            # Color code by urgency
            urgency_text = det.get('urgency', 'N/A').split(' - ')[0]
            
            row = [
                str(det.get('tooth_number', 'N/A')),
                det.get('disease_type', 'N/A'),
                det.get('severity', 'N/A'),
                det.get('affected_area', 'N/A'),
                f"{det.get('confidence', 0):.0%}",
                urgency_text
            ]
            table_data.append(row)
        
        # Create table
        findings_table = Table(table_data, colWidths=[0.7*inch, 1.8*inch, 1*inch, 1*inch, 1*inch, 1*inch])
        
        # Style table
        style = TableStyle([
            # Header row
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#3498DB')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('FONT', (0, 0), (-1, 0), 'Helvetica-Bold', 10),
            ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
            
            # Data rows
            ('FONT', (0, 1), (-1, -1), 'Helvetica', 9),
            ('ALIGN', (0, 1), (0, -1), 'CENTER'),
            ('ALIGN', (4, 1), (5, -1), 'CENTER'),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
            
            # Grid
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#ECF0F1')]),
            
            # Padding
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ])
        
        findings_table.setStyle(style)
        elements.append(findings_table)
        elements.append(Spacer(1, 0.3*inch))
        
        return elements
    
    def _create_recommendations(self, results: dict):
        """Create recommendations section"""
        elements = []
        
        # Section heading
        heading = Paragraph("TREATMENT RECOMMENDATIONS", self.heading_style)
        elements.append(heading)
        
        detections = results.get('detections', [])
        
        # Collect unique recommendations by urgency
        urgent = []
        high = []
        moderate = []
        low = []
        
        for det in detections:
            urgency = det.get('urgency', '')
            tooth_num = det.get('tooth_number')
            disease = det.get('disease_type')
            
            if disease == 'Healthy':
                continue
            
            rec_text = f"<b>Tooth #{tooth_num}</b> ({disease}):"
            
            if 'URGENT' in urgency:
                urgent.append((rec_text, det.get('recommendations', [])))
            elif 'HIGH' in urgency:
                high.append((rec_text, det.get('recommendations', [])))
            elif 'MODERATE' in urgency:
                moderate.append((rec_text, det.get('recommendations', [])))
            else:
                low.append((rec_text, det.get('recommendations', [])))
        
        # Add urgent first
        if urgent:
            elements.append(Paragraph("<b>🚨 URGENT - Immediate Attention Required:</b>", self.body_style))
            for title, recs in urgent:
                elements.append(Paragraph(title, self.body_style))
                for rec in recs[:3]:
                    elements.append(Paragraph(f"  • {rec}", self.body_style))
                elements.append(Spacer(1, 0.1*inch))
        
        # High priority
        if high:
            elements.append(Paragraph("<b>⚠️ HIGH - Schedule Within 1 Week:</b>", self.body_style))
            for title, recs in high:
                elements.append(Paragraph(title, self.body_style))
                for rec in recs[:2]:
                    elements.append(Paragraph(f"  • {rec}", self.body_style))
                elements.append(Spacer(1, 0.1*inch))
        
        # Moderate priority
        if moderate:
            elements.append(Paragraph("<b>📋 MODERATE - Schedule Within 2-4 Weeks:</b>", self.body_style))
            for title, recs in moderate[:3]:  # Limit to avoid cluttering
                elements.append(Paragraph(title, self.body_style))
                for rec in recs[:2]:
                    elements.append(Paragraph(f"  • {rec}", self.body_style))
        
        if not (urgent or high or moderate or low):
            elements.append(Paragraph("✅ No immediate treatment required. Continue regular dental checkups.", self.body_style))
        
        return elements
    
    def _create_footer(self):
        """Create footer section"""
        elements = []
        
        elements.append(Spacer(1, 0.5*inch))
        
        disclaimer = """
        <b>DISCLAIMER:</b> This report is generated by an AI-assisted diagnostic tool and should be 
        used for informational purposes only. It is NOT a substitute for professional dental examination 
        and diagnosis. Please consult with a licensed dentist for proper evaluation and treatment.
        """
        
        elements.append(Paragraph(disclaimer, self.small_style))
        
        return elements


def generate_pdf_report(prediction_results: dict, output_filename: str = None, output_dir: str = "results_pridects") -> str:
    """
    Convenience function to generate PDF report
    
    Args:
        prediction_results: Dictionary with prediction results
        output_filename: Optional custom filename
        output_dir: Directory to save the PDF report
        
    Returns:
        Path to generated PDF file
    """
    generator = PDFReportGenerator(output_dir=output_dir)
    return generator.generate_report(prediction_results, output_filename)
