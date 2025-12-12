import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/reports_provider.dart';

class ReportScreen extends StatefulWidget {
  final String userId;

  const ReportScreen({super.key, required this.userId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Set<int> _expandedReportIndices = {
    0,
  }; // First report expanded by default

  @override
  void initState() {
    super.initState();
    // Load reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadReports(widget.userId);
    });
  }

  void _toggleReportExpansion(int index) {
    setState(() {
      if (_expandedReportIndices.contains(index)) {
        _expandedReportIndices.remove(index);
      } else {
        _expandedReportIndices.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Feed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFF5F5), // Soft warm pink
                        Color(0xFFFFF9E5), // Warm vanilla
                        Color(0xFFF5F5FF), // Soft lavender
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        final isLoading = reportsProvider.isLoading;
        final errorMessage = reportsProvider.errorMessage;
        final reports = reportsProvider.reports;

        if (isLoading && reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B87F5).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF9B87F5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Loading your feed...',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          );
        }

        if (errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Oops!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => reportsProvider.refresh(widget.userId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 40,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No entries yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Record your first check-in\nto start tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => reportsProvider.refresh(widget.userId),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportSection(report, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildReportSection(Report report, int index) {
    final isExpanded = _expandedReportIndices.contains(index);
    final hasContent =
        report.ideas.isNotEmpty ||
        report.feelings.isNotEmpty ||
        report.actionItems.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header - tappable
        GestureDetector(
          onTap: () => _toggleReportExpansion(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              bottom: isExpanded ? 16 : 8,
              top: index == 0 ? 0 : 24,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(color: const Color(0xFF9B87F5), width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.black.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasContent)
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Content sections - animated expansion
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ideas section
                    if (report.ideas.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Ideas',
                        Icons.emoji_objects_outlined,
                        const Color(0xFFFDB43C),
                      ),
                      const SizedBox(height: 12),
                      ...report.ideas.map(
                        (idea) => _buildItemCard(idea, const Color(0xFFFDB43C)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Feelings section
                    if (report.feelings.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Feelings',
                        Icons.favorite_outline,
                        const Color(0xFFFF6B9D),
                      ),
                      const SizedBox(height: 12),
                      ...report.feelings.map(
                        (feeling) =>
                            _buildItemCard(feeling, const Color(0xFFFF6B9D)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action Items section
                    if (report.actionItems.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Action Items',
                        Icons.check_circle_outline,
                        const Color(0xFF4ADE80),
                      ),
                      const SizedBox(height: 12),
                      ...report.actionItems.map(
                        (actionItem) =>
                            _buildItemCard(actionItem, const Color(0xFF4ADE80)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(String content, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today - ${DateFormat.jm().format(date)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday - ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat('EEEE, MMM d - ').format(date) +
          DateFormat.jm().format(date);
    }
  }
}
