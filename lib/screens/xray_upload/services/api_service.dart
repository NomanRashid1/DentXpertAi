import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'config_service.dart';
import 'dio_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final DioService _dioService = DioService();
  final _httpClient = http.Client();

  ApiService._internal();

  // Main method to analyze X-ray
  Future<Uint8List> analyzeXray({
    required File imageFile,
    double confidenceThreshold = 0.25,
  }) async {
    // Validate image first
    if (!validateImage(imageFile)) {
      throw Exception(AppConfig.errorMessages['invalid_image']);
    }

    if (AppConfig.debugMode) {
      print('[ApiService] Starting X-ray analysis...');
      print('[ApiService] Image: ${imageFile.path}');
      print('[ApiService] Size: ${await imageFile.length()} bytes');
    }

    try {
      // Try Dio first (more reliable)
      return await _analyzeWithDio(
        imageFile: imageFile,
        confidenceThreshold: confidenceThreshold,
      );
    } catch (dioError) {
      if (AppConfig.debugMode) {
        print('[ApiService] Dio failed: $dioError');
        print('[ApiService] Trying HTTP fallback...');
      }

      // Fallback to HTTP
      try {
        return await _analyzeWithHttp(
          imageFile: imageFile,
          confidenceThreshold: confidenceThreshold,
        );
      } catch (httpError) {
        if (AppConfig.debugMode) {
          print('[ApiService] HTTP fallback also failed: $httpError');
        }
        throw Exception('Both Dio and HTTP methods failed: $dioError');
      }
    }
  }

  // Method 1: Using Dio (Primary)
  Future<Uint8List> _analyzeWithDio({
    required File imageFile,
    required double confidenceThreshold,
  }) async {
    final completer = Completer<Uint8List>();

    try {
      print('[ApiService] Using Dio for upload...');

      final pdfBytes = await _dioService.uploadXrayAndGetPdf(
        imageFile: imageFile,
        confidenceThreshold: confidenceThreshold,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total * 100).toInt();
            print('[ApiService] 📤 Upload: $progress% ($sent/$total bytes)');
          }
        },
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = (received / total * 100).toInt();
            print(
              '[ApiService] 📥 Download: $progress% ($received/$total bytes)',
            );
          }
        },
      );

      completer.complete(pdfBytes);
    } catch (e) {
      completer.completeError(e);
    }

    return completer.future;
  }

  // Method 2: Using HTTP (Fallback)
  Future<Uint8List> _analyzeWithHttp({
    required File imageFile,
    required double confidenceThreshold,
  }) async {
    if (AppConfig.debugMode) {
      print('[ApiService] Using HTTP fallback...');
    }

    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AppConfig.predictPdfEndpoint),
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: path.basename(imageFile.path),
        ),
      );

      // Add confidence threshold
      request.fields['confidence_threshold'] = confidenceThreshold.toString();

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );

      if (streamedResponse.statusCode == 200) {
        // Read response in chunks
        final chunks = <List<int>>[];
        int totalReceived = 0;

        await for (final chunk in streamedResponse.stream) {
          chunks.add(chunk);
          totalReceived += chunk.length;

          if (AppConfig.debugMode && totalReceived % (100 * 1024) == 0) {
            print('[ApiService] Received: ${totalReceived ~/ 1024} KB');
          }
        }

        // Combine chunks
        final totalLength = chunks.fold<int>(
          0,
          (sum, chunk) => sum + chunk.length,
        );
        final pdfBytes = Uint8List(totalLength);

        int offset = 0;
        for (final chunk in chunks) {
          pdfBytes.setAll(offset, chunk);
          offset += chunk.length;
        }

        if (AppConfig.debugMode) {
          print('[ApiService] ✅ HTTP: Received ${pdfBytes.length} bytes');
        }

        return pdfBytes;
      } else {
        final errorBody = await streamedResponse.stream.bytesToString();
        throw Exception(
          'HTTP Error ${streamedResponse.statusCode}: $errorBody',
        );
      }
    } on TimeoutException {
      throw Exception(AppConfig.errorMessages['timeout_error']);
    } on SocketException {
      throw Exception(AppConfig.errorMessages['network_error']);
    } catch (e) {
      throw Exception('HTTP Request failed: $e');
    }
  }

  // Validate image file
  bool validateImage(File imageFile) {
    try {
      final fileName = path.basename(imageFile.path).toLowerCase();

      // Check if file exists
      if (!imageFile.existsSync()) {
        if (AppConfig.debugMode) {
          print('[ApiService] File does not exist: ${imageFile.path}');
        }
        return false;
      }

      // Check file size
      final fileSize = imageFile.lengthSync();

      if (fileSize < AppConfig.minFileSizeBytes) {
        if (AppConfig.debugMode) {
          print('[ApiService] File too small: $fileSize bytes');
        }
        return false;
      }

      if (fileSize > AppConfig.maxFileSizeBytes) {
        if (AppConfig.debugMode) {
          print('[ApiService] File too large: ${fileSize ~/ (1024 * 1024)}MB');
        }
        return false;
      }

      // Check extension
      final hasValidExtension = AppConfig.validImageExtensions.any(
        (ext) => fileName.endsWith(ext),
      );

      if (!hasValidExtension) {
        if (AppConfig.debugMode) {
          print('[ApiService] Invalid extension: $fileName');
        }
        return false;
      }

      // Check keywords (optional)
      final hasValidKeyword = AppConfig.validImageKeywords.any(
        (keyword) => fileName.contains(keyword),
      );

      if (!hasValidKeyword) {
        if (AppConfig.debugMode) {
          print('[ApiService] Warning: No dental keywords in filename');
        }
        // Don't fail just based on keywords - some users might rename files
      }

      return true;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('[ApiService] Validation error: $e');
      }
      return false;
    }
  }

  // Test API connection
  Future<bool> testApiConnection() async {
    try {
      final response = await _httpClient
          .get(Uri.parse(AppConfig.apiBaseUrl))
          .timeout(const Duration(seconds: 10));

      if (AppConfig.debugMode) {
        print('[ApiService] Connection test: ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (AppConfig.debugMode) {
        print('[ApiService] Connection test failed: $e');
      }
      return false;
    }
  }

  // Clean up
  void dispose() {
    _httpClient.close();
    _dioService.cancelAllRequests();
  }
}
