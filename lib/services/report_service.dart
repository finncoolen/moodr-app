import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/report.dart';

class ReportService {
  // Use the same base URL as TranscriptionService
  static const String _baseUrl = 'http://192.168.1.248:8000';

  /// Fetch the latest report for a given user ID
  /// Returns the Report object or null if no report exists
  Future<Report?> getLatestReport(String userId) async {
    final uri = Uri.parse(
      '$_baseUrl/report/latest',
    ).replace(queryParameters: {'user_id': userId});

    try {
      final response = await http
          .get(uri)
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
          return null; // No reports found
        }

        // Parse the latest report
        final reportData = jsonResponse['latest_report'];
        return Report.fromJson(reportData);
      } else {
        throw Exception(
          'Failed to fetch report with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
