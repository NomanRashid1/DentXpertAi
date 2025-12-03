import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' hide MultipartFile;
import 'package:path/path.dart' as path;
import 'config_service.dart';

class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  late Dio _dio;

  DioService._internal() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        sendTimeout: Duration(seconds: AppConfig.sendTimeoutSeconds),
        headers: {
          'Accept': 'application/json, application/pdf, */*',
          'User-Agent': 'DentalAI-Flutter/1.0',
        },
        contentType: Headers.multipartFormDataContentType,
        responseType: ResponseType.bytes,
      ),
    );

    // Add interceptors for logging
    if (AppConfig.logNetworkRequests) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: false, // Don't log binary PDF data
          error: true,
          logPrint: (object) {
            if (AppConfig.debugMode) {
              print('[DIO] $object');
            }
          },
        ),
      );
    }

    // Add error interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AppConfig.debugMode) {
            print('[DIO] Request: ${options.method} ${options.path}');
            print('[DIO] Headers: ${options.headers}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.debugMode) {
            print('[DIO] Response: ${response.statusCode}');
            print('[DIO] Response Headers: ${response.headers}');
            if (response.data is Uint8List) {
              print(
                '[DIO] Response Size: ${(response.data as Uint8List).length} bytes',
              );
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (AppConfig.debugMode) {
            print('[DIO] Error: ${e.type}');
            print('[DIO] Error Message: ${e.message}');
            print('[DIO] Response: ${e.response?.data}');
            print('[DIO] Stack Trace: ${e.stackTrace}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Upload image and get PDF
  Future<Uint8List> uploadXrayAndGetPdf({
    required File imageFile,
    double confidenceThreshold = 0.25,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('[DioService] Starting upload...');
        print('[DioService] Image path: ${imageFile.path}');
        print('[DioService] File size: ${await imageFile.length()} bytes');
      }

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
          contentType: MediaType('image', 'png'), // Adjust based on file type
        ),
        'confidence_threshold': confidenceThreshold.toString(),
      });

      // Send request
      final response = await _dio.post<Uint8List>(
        '/api/predict-pdf',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        ),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (response.statusCode == 200) {
        final pdfBytes = response.data;

        if (pdfBytes == null) {
          throw Exception('Received null response from server');
        }

        if (pdfBytes.isEmpty) {
          throw Exception('Received empty PDF from server');
        }

        if (AppConfig.debugMode) {
          print('[DioService] ✅ PDF received successfully');
          print('[DioService] PDF size: ${pdfBytes.length} bytes');

          // Check if it's actually a PDF
          if (pdfBytes.length > 4) {
            final header = String.fromCharCodes(pdfBytes.sublist(0, 4));
            print('[DioService] File header: $header');

            if (header == '%PDF') {
              print('[DioService] ✅ Valid PDF file');
            } else {
              print('[DioService] ⚠️ Not a standard PDF file');
            }
          }
        }

        return pdfBytes;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (AppConfig.debugMode) {
        print('[DioService] ❌ DioException: ${e.type}');
        print('[DioService] Message: ${e.message}');
        print('[DioService] Error: ${e.error}');
      }

      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Connection timeout. Please check your network.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Upload timeout. File might be too large.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Server is taking too long to respond.';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'SSL certificate error.';
          break;
        case DioExceptionType.badResponse:
          if (e.response != null) {
            try {
              final errorData = String.fromCharCodes(
                e.response!.data as List<int>,
              );
              errorMessage = 'Server error: $errorData';
            } catch (_) {
              errorMessage = 'Server error: ${e.response!.statusCode}';
            }
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request cancelled.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Connection error. Check if server is running.';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Unknown error: ${e.message}';
          break;
      }

      throw Exception(errorMessage);
    } catch (e) {
      if (AppConfig.debugMode) {
        print('[DioService] ❌ Unknown error: $e');
      }
      rethrow;
    }
  }

  // Test server connection
  Future<bool> testConnection() async {
    try {
      final response = await _dio.get(
        '/',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.plain,
        ),
      );

      if (AppConfig.debugMode) {
        print('[DioService] Connection test: ${response.statusCode}');
        print('[DioService] Server response: ${response.data}');
      }

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (AppConfig.debugMode) {
        print('[DioService] Connection test failed: ${e.type}');
      }
      return false;
    }
  }

  // Get server health status
  Future<Map<String, dynamic>?> getServerHealth() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/health',
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.data;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('[DioService] Health check failed: $e');
      }
      return null;
    }
  }

  // Cancel all ongoing requests
  void cancelAllRequests() {
    _dio.close(force: true);
  }

  // Send email with PDF attachment via backend
  Future<Map<String, dynamic>> sendEmailWithPdf({
    required Uint8List pdfBytes,
    required String toEmail,
    required String patientName,
    String? age,
    String? gender,
    String? contact,
    String pdfFilename = 'dental_report.pdf',
  }) async {
    try {
      if (AppConfig.debugMode) {
        print('[DioService] Sending email to: $toEmail');
        print('[DioService] Patient: $patientName');
        print('[DioService] PDF size: ${pdfBytes.length} bytes');
      }

      // Create form data
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          pdfBytes,
          filename: pdfFilename,
          contentType: MediaType('application', 'pdf'),
        ),
        'to_email': toEmail,
        'patient_name': patientName,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (contact != null) 'contact': contact,
      });

      // Send request
      final response = await _dio.post(
        '/api/send-email',
        data: formData,
        options: Options(
          responseType: ResponseType.json,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        if (AppConfig.debugMode) {
          print('[DioService] ✅ Email sent successfully');
        }
        return {'success': true, 'message': 'Email sent successfully'};
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (AppConfig.debugMode) {
        print('[DioService] ❌ Email failed: ${e.type}');
        print('[DioService] Message: ${e.message}');
      }

      String errorMessage;
      if (e.response != null && e.response!.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = 'Email failed: ${errorData['error']}';
          } else {
            errorMessage = 'Email failed: ${e.response!.statusCode}';
          }
        } catch (_) {
          errorMessage = 'Email failed: Server error';
        }
      } else {
        errorMessage = 'Email failed: ${e.message ?? 'Unknown error'}';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      if (AppConfig.debugMode) {
        print('[DioService] ❌ Unexpected error: $e');
      }
      return {'success': false, 'message': 'Email failed: $e'};
    }
  }

  // Get Dio instance (for advanced use)
  Dio get dioInstance => _dio;
}
