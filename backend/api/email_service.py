"""
Email Service Module for Dental X-ray Reports
Sends emails with PDF attachments using SMTP
Supports Gmail, SendGrid, and custom SMTP servers
"""

import smtplib
import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from datetime import datetime
from typing import Optional


class EmailService:
    """Email service for sending dental reports via SMTP"""
    
    def __init__(self):
        """Initialize email service with environment configuration"""
        self.smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.getenv('SMTP_PORT', '587'))
        self.smtp_user = os.getenv('SMTP_USER', '')
        self.smtp_password = os.getenv('SMTP_PASSWORD', '')
        self.from_email = os.getenv('FROM_EMAIL', self.smtp_user)
        self.from_name = os.getenv('FROM_NAME', 'DentXpert AI')
        
        # Validate configuration
        if not self.smtp_user or not self.smtp_password:
            print("⚠️  Email service not configured. Set SMTP_USER and SMTP_PASSWORD in .env file")
            self.enabled = False
        else:
            self.enabled = True
            print(f"✅ Email service initialized ({self.smtp_server})")
    
    def send_report_email(
        self, 
        to_email: str, 
        patient_name: str,
        pdf_bytes: bytes,
        pdf_filename: str = "dental_report.pdf",
        patient_details: Optional[dict] = None
    ) -> dict:
        """
        Send dental report email with PDF attachment
        
        Args:
            to_email: Recipient email address
            patient_name: Patient's name
            pdf_bytes: PDF file content as bytes
            pdf_filename: Name for the PDF attachment
            patient_details: Optional dict with age, gender, contact, etc.
            
        Returns:
            dict: {'success': bool, 'message': str}
        """
        if not self.enabled:
            return {
                'success': False, 
                'message': 'Email service not configured. Please set SMTP credentials in .env file'
            }
        
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['Subject'] = f'Dental X-ray Analysis Report - {patient_name}'
            msg['From'] = f'{self.from_name} <{self.from_email}>'
            msg['To'] = to_email
            msg['Date'] = datetime.now().strftime('%a, %d %b %Y %H:%M:%S %z')
            
            # Create HTML email body
            html_body = self._create_email_body(patient_name, patient_details)
            msg.attach(MIMEText(html_body, 'html'))
            
            # Attach PDF
            pdf_attachment = MIMEApplication(pdf_bytes, _subtype='pdf')
            pdf_attachment.add_header('Content-Disposition', 'attachment', filename=pdf_filename)
            msg.attach(pdf_attachment)
            
            # Send email
            print(f"📧 Sending email to {to_email}...")
            
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.smtp_user, self.smtp_password)
                server.send_message(msg)
            
            print(f"✅ Email sent successfully to {to_email}")
            return {
                'success': True,
                'message': f'Email sent successfully to {to_email}'
            }
            
        except smtplib.SMTPAuthenticationError:
            error_msg = 'SMTP authentication failed. Please check your email credentials.'
            print(f"❌ {error_msg}")
            return {'success': False, 'message': error_msg}
            
        except smtplib.SMTPException as e:
            error_msg = f'SMTP error: {str(e)}'
            print(f"❌ {error_msg}")
            return {'success': False, 'message': error_msg}
            
        except Exception as e:
            error_msg = f'Failed to send email: {str(e)}'
            print(f"❌ {error_msg}")
            return {'success': False, 'message': error_msg}
    
    def _create_email_body(self, patient_name: str, patient_details: Optional[dict]) -> str:
        """Create HTML email body"""
        
        # Extract patient details
        age = patient_details.get('age', 'N/A') if patient_details else 'N/A'
        gender = patient_details.get('gender', 'N/A') if patient_details else 'N/A'
        contact = patient_details.get('contact', 'N/A') if patient_details else 'N/A'
        date = datetime.now().strftime('%B %d, %Y')
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: #333;
                    max-width: 600px;
                    margin: 0 auto;
                    padding: 20px;
                }}
                .header {{
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 30px;
                    border-radius: 10px 10px 0 0;
                    text-align: center;
                }}
                .header h1 {{
                    margin: 0;
                    font-size: 28px;
                }}
                .content {{
                    background: #f8f9fa;
                    padding: 30px;
                    border-radius: 0 0 10px 10px;
                }}
                .patient-info {{
                    background: white;
                    padding: 20px;
                    border-radius: 8px;
                    margin: 20px 0;
                    border-left: 4px solid #667eea;
                }}
                .info-row {{
                    display: flex;
                    padding: 8px 0;
                    border-bottom: 1px solid #e9ecef;
                }}
                .info-label {{
                    font-weight: bold;
                    width: 120px;
                    color: #667eea;
                }}
                .info-value {{
                    flex: 1;
                    color: #495057;
                }}
                .footer {{
                    margin-top: 30px;
                    padding-top: 20px;
                    border-top: 2px solid #e9ecef;
                    font-size: 12px;
                    color: #6c757d;
                    text-align: center;
                }}
                .btn {{
                    background: #667eea;
                    color: white;
                    padding: 12px 24px;
                    border-radius: 6px;
                    text-decoration: none;
                    display: inline-block;
                    margin: 20px 0;
                }}
            </style>
        </head>
        <body>
            <div class="header">
                <h1>🦷 DentXpert AI</h1>
                <p style="margin: 10px 0 0 0; opacity: 0.9;">Dental X-ray Analysis Report</p>
            </div>
            
            <div class="content">
                <p>Dear Healthcare Provider,</p>
                
                <p>Please find attached the dental X-ray analysis report for the following patient:</p>
                
                <div class="patient-info">
                    <h3 style="margin-top: 0; color: #667eea;">Patient Information</h3>
                    <div class="info-row">
                        <span class="info-label">Patient Name:</span>
                        <span class="info-value">{patient_name}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Age:</span>
                        <span class="info-value">{age}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Gender:</span>
                        <span class="info-value">{gender}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Contact:</span>
                        <span class="info-value">{contact}</span>
                    </div>
                    <div class="info-row" style="border-bottom: none;">
                        <span class="info-label">Report Date:</span>
                        <span class="info-value">{date}</span>
                    </div>
                </div>
                
                <p><strong>📎 Attachment:</strong> The detailed analysis report with AI-powered tooth detection and diagnostic insights is attached as a PDF file.</p>
                
                <p style="background: #fff3cd; padding: 15px; border-radius: 6px; border-left: 4px solid #ffc107;">
                    <strong>⚕️ Note:</strong> This AI-generated report is intended to assist healthcare professionals. 
                    Please review the findings and correlate with clinical examination for accurate diagnosis and treatment planning.
                </p>
                
                <div class="footer">
                    <p><strong>DentXpert AI</strong> - Advanced Dental X-ray Analysis</p>
                    <p>Powered by YOLOv8 & Google Gemini AI</p>
                    <p style="margin-top: 15px; font-size: 11px;">
                        This is an automated email. Please do not reply to this message.
                    </p>
                </div>
            </div>
        </body>
        </html>
        """
        
        return html


# Global email service instance
email_service = EmailService()
