import 'package:flutter/foundation.dart';

import '../models/report.dart';
import '../services/report_service.dart';

/// Represents a reminder with tracking information
class ReminderItem {
  final String text;
  final String reportId;
  final int index;
  final DateTime createdAt;

  ReminderItem({
    required this.text,
    required this.reportId,
    required this.index,
    required this.createdAt,
  });
}

class ReportsProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get all reminders from all reports with tracking info
  List<ReminderItem> get reminders {
    final allReminders = <ReminderItem>[];
    for (final report in _reports) {
      for (int i = 0; i < report.reminders.length; i++) {
        allReminders.add(
          ReminderItem(
            text: report.reminders[i],
            reportId: report.id,
            index: i,
            createdAt: report.createdAt,
          ),
        );
      }
    }
    return allReminders;
  }

  /// Load reports for a given user ID (with optional force refresh)
  Future<void> loadReports(String userId, {bool forceRefresh = false}) async {
    // Skip if we have data and it's recent (less than 5 minutes old)
    if (!forceRefresh &&
        _reports.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(minutes: 20)) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reports = await _reportService.getReports30Days(userId);
      _reports = reports;
      _lastFetchTime = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load reports: $e';
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force refresh the reports
  Future<void> refresh(String userId) async {
    return loadReports(userId, forceRefresh: true);
  }

  /// Delete a reminder from a specific report
  Future<void> deleteReminder(String reportId, int reminderIndex) async {
    try {
      // Find the report in local cache
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) return;

      final report = _reports[reportIndex];

      // Create updated reminders list without the deleted item
      final updatedReminders = List<String>.from(report.reminders)
        ..removeAt(reminderIndex);

      // Update Supabase
      await _reportService.updateReportReminders(reportId, updatedReminders);

      // Update local cache
      final updatedReport = Report(
        id: report.id,
        ideas: report.ideas,
        feelings: report.feelings,
        reminders: updatedReminders,
        actionItems: report.actionItems,
        createdAt: report.createdAt,
      );

      _reports[reportIndex] = updatedReport;
      notifyListeners();
    } catch (e) {
      // Optionally handle error
      rethrow;
    }
  }

  /// Clear all cached data
  void clear() {
    _reports = [];
    _lastFetchTime = null;
    _errorMessage = null;
    notifyListeners();
  }
}
