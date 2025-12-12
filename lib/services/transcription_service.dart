import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class TranscriptionService {
  static final String _baseUrl = AppConfig.apiBaseUrl;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Transcribe an audio file using the FastAPI backend
  /// Returns the transcribed text or status message
  /// Includes retry logic for failed uploads
  Future<String> transcribeAudio(String filePath, String userId) async {
    const maxRetries = 3;
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxRetries) {
      try {
        return await _uploadAudio(filePath, userId);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;

        if (attempt < maxRetries) {
          // Wait before retrying (exponential backoff: 2s, 4s, 8s)
          await Future.delayed(Duration(seconds: 2 * attempt));
          debugPrint(
            'Retry attempt $attempt/$maxRetries for transcription upload',
          );
        }
      }
    }

    // All retries failed
    throw lastException ??
        Exception('Upload failed after $maxRetries attempts');
  }

  /// Internal method to upload audio file
  Future<String> _uploadAudio(String filePath, String userId) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Audio file not found');
    }

    final uri = Uri.parse(
      '$_baseUrl/upload/audio/',
    ).replace(queryParameters: {'user_id': userId});

    // Create multipart request
    final request = http.MultipartRequest('POST', uri);

    // Add authentication token
    final token = _supabase.auth.currentSession?.accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add the audio file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: filePath.split('/').last,
      ),
    );

    // Send the request
    final streamedResponse = await request.send().timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        throw Exception('Request timed out');
      },
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Backend returns status and message for queued transcription
      return jsonResponse['message'] ?? 'Transcription queued successfully';
    } else {
      throw Exception(
        'Upload failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }
}
