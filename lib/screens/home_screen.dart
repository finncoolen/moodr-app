import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recording_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moodr'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Transcription text box - takes up available space
              Expanded(
                child: Consumer<RecordingProvider>(
                  builder: (context, provider, child) {
                    return _TranscriptionBox(provider: provider);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Recording button at the bottom
              Consumer<RecordingProvider>(
                builder: (context, provider, child) {
                  return _RecordingButton(provider: provider);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranscriptionBox extends StatelessWidget {
  final RecordingProvider provider;

  const _TranscriptionBox({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: SingleChildScrollView(child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    switch (provider.state) {
      case RecordingState.idle:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic_none_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap the button below to start recording',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case RecordingState.recording:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Recording...',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.remainingSeconds} seconds remaining',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Processing audio...',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );

      case RecordingState.completed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Transcription',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(provider.transcribedText, style: textTheme.bodyLarge),
          ],
        );

      case RecordingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
  }
}

class _RecordingButton extends StatelessWidget {
  final RecordingProvider provider;

  const _RecordingButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecording = provider.isRecording;
    final isProcessing = provider.state == RecordingState.processing;

    return Column(
      children: [
        // Main recording button
        GestureDetector(
          onTap: isProcessing ? null : _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? 80 : 72,
            height: isRecording ? 80 : 72,
            decoration: BoxDecoration(
              color: isProcessing
                  ? colorScheme.surfaceContainerHighest
                  : isRecording
                  ? colorScheme.error
                  : colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isRecording ? colorScheme.error : colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: isRecording ? 20 : 10,
                  spreadRadius: isRecording ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              isProcessing
                  ? Icons.hourglass_empty
                  : isRecording
                  ? Icons.stop
                  : Icons.mic,
              color: isProcessing
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onPrimary,
              size: 32,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Button label
        Text(
          _getButtonLabel(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),

        // Reset button when completed or error
        if (provider.state == RecordingState.completed ||
            provider.state == RecordingState.error) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: provider.reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Record Again'),
          ),
        ],
      ],
    );
  }

  String _getButtonLabel() {
    switch (provider.state) {
      case RecordingState.idle:
        return 'Tap to record (1 min max)';
      case RecordingState.recording:
        return 'Tap to stop';
      case RecordingState.processing:
        return 'Processing...';
      case RecordingState.completed:
        return 'Recording complete';
      case RecordingState.error:
        return 'Try again';
    }
  }

  void _handleTap() {
    if (provider.isRecording) {
      provider.stopRecording();
    } else if (provider.state == RecordingState.idle ||
        provider.state == RecordingState.completed ||
        provider.state == RecordingState.error) {
      provider.startRecording();
    }
  }
}
