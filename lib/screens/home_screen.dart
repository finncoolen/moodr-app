import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recording_provider.dart';
import '../providers/reports_provider.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load reports when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recordingProvider = context.read<RecordingProvider>();
      final reportsProvider = context.read<ReportsProvider>();

      // Load initial reports
      reportsProvider.loadReports(recordingProvider.userId);

      // Set up callback to refresh reports after transcription completes
      recordingProvider.onTranscriptionComplete = () {
        reportsProvider.refresh(recordingProvider.userId);
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Daily status indicator
                    Consumer<RecordingProvider>(
                      builder: (context, provider, child) {
                        return _DailyStatusIndicator(
                          hasRecordedToday: provider.hasRecordedToday,
                          recordingState: provider.state,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Main content - reminders box (always visible) or recording/processing status
                    Expanded(
                      child: Consumer<RecordingProvider>(
                        builder: (context, provider, child) {
                          // Show transcription status only when recording or processing
                          if (provider.state == RecordingState.recording ||
                              provider.state == RecordingState.processing) {
                            return _TranscriptionBox(provider: provider);
                          }
                          // For all other states (idle, completed, error), show reminders
                          return _buildRemindersBox();
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bottom section with recording button and report icon
                    SizedBox(
                      height: 140, // Fixed height for the bottom section
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Settings button in bottom left
                            Consumer<RecordingProvider>(
                              builder: (context, provider, child) {
                                if (provider.state !=
                                        RecordingState.recording &&
                                    provider.state !=
                                        RecordingState.processing) {
                                  return GestureDetector(
                                    onTap: () => _navigateToSettings(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.deepPurple.shade200,
                                            Colors.purple.shade300,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.deepPurple
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.settings,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Recording button in center bottom
                            Consumer<RecordingProvider>(
                              builder: (context, provider, child) {
                                return _RecordingButton(provider: provider);
                              },
                            ),

                            // Report button in bottom right
                            Consumer<RecordingProvider>(
                              builder: (context, provider, child) {
                                if (provider.state !=
                                        RecordingState.recording &&
                                    provider.state !=
                                        RecordingState.processing) {
                                  return GestureDetector(
                                    onTap: () => _navigateToReport(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.deepPurple.shade300,
                                            Colors.purple.shade400,
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.deepPurple
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.article_outlined,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToReport(BuildContext context) {
    final provider = context.read<RecordingProvider>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportScreen(userId: provider.userId),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Widget _buildRemindersBox() {
    return Consumer<ReportsProvider>(
      builder: (context, reportsProvider, child) {
        final isLoading = reportsProvider.isLoading;
        final reminders = reportsProvider.reminders;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF9B87F5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading reminders...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 48,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Reminders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_active,
                          size: 24,
                          color: Color(0xFF9B87F5),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Your Reminders',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9B87F5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = reminders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B87F5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF9B87F5).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF9B87F5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reminder.text,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      _deleteReminder(context, reminder),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _deleteReminder(BuildContext context, dynamic reminder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
        content: Text(
          'Are you sure you want to delete this reminder?\n\n"${reminder.text}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<ReportsProvider>().deleteReminder(
          reminder.reportId,
          reminder.index,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reminder deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete reminder: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

class _TranscriptionBox extends StatelessWidget {
  final RecordingProvider provider;

  const _TranscriptionBox({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (provider.state) {
      case RecordingState.recording:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Recording...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${provider.remainingSeconds}s remaining',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
        );

      case RecordingState.processing:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating gradient ring
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value * 6.28318, // 2 * PI
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                const Color(0xFF9B87F5),
                                const Color(0xFF9B87F5).withOpacity(0.1),
                                const Color(0xFF9B87F5),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Restart animation by rebuilding
                    },
                  ),
                  // Inner circle
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B87F5).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF9B87F5),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Processing...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Analyzing your reflection',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.5),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );

      case RecordingState.idle:
      case RecordingState.completed:
      case RecordingState.error:
        // These states are now handled by showing the reminders box instead
        // This fallback should not be reached in normal flow
        return const SizedBox.shrink();
    }
  }
}

class _RecordingButton extends StatefulWidget {
  final RecordingProvider provider;

  const _RecordingButton({required this.provider});

  @override
  State<_RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<_RecordingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for idle state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Scale animation for tap
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Start pulse animation only if recording not completed
    if (!widget.provider.hasRecordedToday) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Stop pulse animation when recording is completed
    if (widget.provider.hasRecordedToday && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    } else if (!widget.provider.hasRecordedToday &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = widget.provider.isRecording;
    final isProcessing = widget.provider.state == RecordingState.processing;
    final progress = isRecording
        ? (60 - widget.provider.remainingSeconds) / 60
        : 0.0;

    return Column(
      children: [
        // Main recording button with progress ring
        GestureDetector(
          onTapDown: (_) {
            _scaleController.forward();
          },
          onTapUp: (_) {
            _scaleController.reverse();
            if (!isProcessing) _handleTap();
          },
          onTapCancel: () {
            _scaleController.reverse();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow/pulse ring (only when not recording)
                    if (!isRecording && !isProcessing)
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.deepPurple.withOpacity(0.1),
                          ),
                        ),
                      ),

                    // Progress ring (during recording)
                    if (isRecording)
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: Colors.black.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B6B),
                          ),
                        ),
                      ),

                    // Main button with gradient
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: _getButtonGradient(isRecording, isProcessing),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getButtonColor(
                              isRecording,
                              isProcessing,
                            ).withOpacity(0.4),
                            blurRadius: isRecording ? 28 : 20,
                            spreadRadius: isRecording ? 2 : 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: isRecording
                          ? _WaveformVisualizer(
                              color: Colors.white.withOpacity(0.3),
                            )
                          : Icon(
                              _getButtonIcon(isRecording, isProcessing),
                              color: Colors.white,
                              size: 36,
                            ),
                    ),

                    // Center icon overlay for recording state
                    if (isRecording)
                      Icon(Icons.stop_rounded, color: Colors.white, size: 36),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Button label with fade animation
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _getButtonLabel(),
            key: ValueKey(_getButtonLabel()),
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _getButtonGradient(bool isRecording, bool isProcessing) {
    if (isProcessing) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB8A4FF), Color(0xFF9B87F5)],
      );
    } else if (isRecording) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF8A8A), Color(0xFFFF6B6B)],
      );
    } else if (widget.provider.hasRecordedToday) {
      // Paler pinky purple gradient for completed state
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 218, 189, 250),
          Color.fromARGB(255, 189, 145, 250),
        ],
      );
    } else {
      // Purple gradient for idle state
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
      );
    }
  }

  Color _getButtonColor(bool isRecording, bool isProcessing) {
    if (isProcessing) {
      return const Color(0xFF9B87F5);
    } else if (isRecording) {
      return const Color(0xFFFF6B6B);
    } else if (widget.provider.hasRecordedToday) {
      return const Color(0xFFD4B5FF);
    } else {
      return Colors.deepPurple;
    }
  }

  IconData _getButtonIcon(bool isRecording, bool isProcessing) {
    if (isProcessing) {
      return Icons.hourglass_empty_rounded;
    } else if (isRecording) {
      return Icons.stop_rounded;
    } else {
      return Icons.mic_rounded;
    }
  }

  String _getButtonLabel() {
    switch (widget.provider.state) {
      case RecordingState.idle:
        return 'Start recording';
      case RecordingState.recording:
        return 'Tap to stop';
      case RecordingState.processing:
        return 'Processing...';
      case RecordingState.completed:
        return 'Complete';
      case RecordingState.error:
        return 'Try again';
    }
  }

  void _handleTap() {
    if (widget.provider.isRecording) {
      widget.provider.stopRecording();
    } else if (widget.provider.state == RecordingState.idle ||
        widget.provider.state == RecordingState.completed ||
        widget.provider.state == RecordingState.error) {
      widget.provider.startRecording();
    }
  }
}

// Waveform visualizer widget
class _WaveformVisualizer extends StatefulWidget {
  final Color color;

  const _WaveformVisualizer({required this.color});

  @override
  State<_WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<_WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WaveformPainter(
            animation: _controller.value,
            color: widget.color,
          ),
          size: const Size(80, 80),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double animation;
  final Color color;

  _WaveformPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    // Create waveform with 5 bars
    for (int i = 0; i < 5; i++) {
      final x = size.width * 0.2 + (i * size.width * 0.15);
      final offset = (animation + i * 0.2) % 1.0;
      final height = 15 + (10 * (0.5 + 0.5 * (offset * 2 - 1).abs()));

      canvas.drawLine(
        Offset(x, centerY - height),
        Offset(x, centerY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) => true;
}

class _DailyStatusIndicator extends StatelessWidget {
  final bool hasRecordedToday;
  final RecordingState recordingState;

  const _DailyStatusIndicator({
    required this.hasRecordedToday,
    required this.recordingState,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayName = _getDayName(today.weekday);
    final date = '${_getMonthName(today.month)} ${today.day}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayName, $date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today\'s reflection',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  hasRecordedToday || recordingState == RecordingState.completed
                  ? const Color(0xFF7ED957).withOpacity(0.15)
                  : const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasRecordedToday || recordingState == RecordingState.completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color:
                      hasRecordedToday ||
                          recordingState == RecordingState.completed
                      ? const Color(0xFF7ED957)
                      : const Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 6),
                Text(
                  hasRecordedToday || recordingState == RecordingState.completed
                      ? 'Complete'
                      : 'Pending',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        hasRecordedToday ||
                            recordingState == RecordingState.completed
                        ? const Color(0xFF7ED957)
                        : const Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

// Typewriter animation widget
class _TypewriterText extends StatefulWidget {
  final String text;

  const _TypewriterText({required this.text});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    if (_currentIndex < widget.text.length) {
      Future.delayed(const Duration(milliseconds: 20), () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _displayedText = widget.text.substring(0, _currentIndex);
          });
          _startTyping();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: TextStyle(
        fontSize: 16,
        height: 1.7,
        color: Colors.black.withOpacity(0.8),
        letterSpacing: 0.2,
      ),
    );
  }
}
