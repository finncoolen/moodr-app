import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../models/report.dart';

class ReportService {
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

  /// Fetch all reports for a given user ID in the last 30 days
  /// Returns a list of Report objects
  Future<List<Report>> getReports30Days(String userId) async {
    final uri = Uri.parse(
      '$_baseUrl/report/latest/30days',
    ).replace(queryParameters: {'user_id': userId});

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if there's an error status
        if (jsonResponse['status'] == 'error') {
          return []; // No reports found
        }

        // Parse the reports
        final reportsData = jsonResponse['latest_reports'] as List;
        return reportsData.map((data) => Report.fromJson(data)).toList();
      } else {
        throw Exception(
          'Failed to fetch reports with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update reminders for a specific report
  Future<void> updateReportReminders(
    String reportId,
    List<String> reminders,
  ) async {
    final uri = Uri.parse('$_baseUrl/report/$reportId');

    try {
      final headers = await _getHeaders();
      final response = await http
          .patch(
            uri,
            headers: headers,
            body: jsonEncode({'reminders': reminders}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update report with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
