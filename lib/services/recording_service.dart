import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class RecordingService {
  static final String _baseUrl = AppConfig.apiBaseUrl;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final token = _supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Check if user can record today
  /// Returns a map with can_record, has_recorded_today, and last_recording_date
  Future<Map<String, dynamic>> canRecordToday() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl/recording/can-record-today'),
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to check recording status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
