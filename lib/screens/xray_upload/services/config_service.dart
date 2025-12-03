import 'package:flutter/material.dart';

class AppConfig {
  // ========== EMAILJS CONFIGURATION ==========
  // Get these from EmailJS Dashboard
  static const String emailjsServiceId = 'service_8u9ofvb';
  static const String emailjsTemplateId = 'template_1akngrf';
  static const String emailjsPublicKey = 'fWUwMsZf_lPd1j8pe';
  static const String emailjsPrivateKey =
      '6Qtsx833gVj5tRzur8w9F'; // Optional, for private templates

  // ========== API CONFIGURATION ==========
  // For Android Emulator: 10.0.2.2
  // For iOS Simulator: 127.0.0.1
  // For Physical Device: Your computer's IP
  static const String apiBaseUrl = 'http://10.0.2.2:5000';
  static const String predictPdfEndpoint = '$apiBaseUrl/api/predict-pdf';

  // API Timeouts
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 120;
  static const int sendTimeoutSeconds = 30;

  // ========== APP CONFIGURATION ==========
  static const String appName = 'Dental AI Assistant';
  static const Color primaryColor = Color(0xFF001F3F);
  static const Color accentColor = Colors.cyanAccent;
  static const Color backgroundColor = Color(0xFF001F3F);
  static const Color cardColor = Color.fromRGBO(255, 255, 255, 0.04);

  // ========== VALIDATION CONFIG ==========
  static final List<String> validImageKeywords = [
    'xray',
    'x-ray',
    'x_ray',
    'xray',
    'tooth',
    'teeth',
    'dental',
    'panoramic',
    'periapical',
    'bitewing',
    'opg',
    'radiograph',
    'radiography',
  ];

  static final List<String> validImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.tiff',
    '.tif',
    '.webp',
  ];

  // ========== FILE SIZE LIMITS ==========
  static const int maxFileSizeBytes = 15 * 1024 * 1024; // 15MB
  static const int minFileSizeBytes = 1024; // 1KB

  // ========== DEBUG SETTINGS ==========
  static const bool debugMode = true;
  static const bool logNetworkRequests = true;
  static const bool logEmailEvents = true;

  // ========== EMAIL TEMPLATE VARIABLES ==========
  static Map<String, dynamic> getEmailTemplateParams({
    required String toEmail,
    required String patientName,
    required String patientInfo,
    required String analysisSummary,
    required String reportId,
  }) {
    return {
      'to_email': toEmail,
      'patient_name': patientName,
      'patient_info': patientInfo,
      'analysis_summary': analysisSummary,
      'analysis_date': DateTime.now().toLocal().toString(),
      'report_id': reportId,
      'app_name': appName,
      'current_year': DateTime.now().year.toString(),
    };
  }

  // ========== ERROR MESSAGES ==========
  static const Map<String, String> errorMessages = {
    'network_error': 'Network connection error. Please check your internet.',
    'timeout_error': 'Request timed out. Server is taking too long to respond.',
    'file_too_large': 'File is too large. Maximum size is 15MB.',
    'invalid_image': 'Invalid image file. Please upload a dental X-ray image.',
    'email_failed': 'Failed to send email. Report was generated successfully.',
    'api_error': 'Server error. Please try again later.',
    'unknown_error': 'An unexpected error occurred.',
  };
}
