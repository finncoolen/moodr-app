import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TranscriptionService {
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For iOS simulator, localhost works
  // For physical devices, use your computer's local IP address
  static const String _baseUrl = 'http://192.168.1.248:8000';

  /// Transcribe an audio file using the FastAPI backend
  /// Returns the transcribed text or status message
  Future<String> transcribeAudio(String filePath, String userId) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Audio file not found');
    }

    final uri = Uri.parse(
      '$_baseUrl/upload/audio/',
    ).replace(queryParameters: {'user_id': userId});

    // Create multipart request
    final request = http.MultipartRequest('POST', uri);

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
