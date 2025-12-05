import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/transcription_service.dart';

enum RecordingState { idle, recording, processing, completed, error }

class RecordingProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final TranscriptionService _transcriptionService = TranscriptionService();

  // User ID for API requests (hardcoded for now, can be replaced with auth later)
  final String _userId = 'user_123';

  RecordingState _state = RecordingState.idle;
  String _transcribedText = '';
  String? _audioFilePath;
  String _errorMessage = '';
  int _remainingSeconds = 60;
  Timer? _recordingTimer;
  bool _hasRecordedToday = false;

  // Getters
  RecordingState get state => _state;
  String get transcribedText => _transcribedText;
  String? get audioFilePath => _audioFilePath;
  String get errorMessage => _errorMessage;
  int get remainingSeconds => _remainingSeconds;
  bool get isRecording => _state == RecordingState.recording;
  String get userId => _userId;
  bool get hasRecordedToday => _hasRecordedToday;
  bool get canRecord =>
      !_hasRecordedToday && _state != RecordingState.completed;

  RecordingProvider() {
    _checkDailyUsage();
  }

  /// Check if user has already recorded today
  Future<void> _checkDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRecordingDate = prefs.getString('last_recording_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    _hasRecordedToday = lastRecordingDate == today;
    notifyListeners();
  }

  /// Mark today as recorded
  Future<void> _markTodayAsRecorded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('last_recording_date', today);
    _hasRecordedToday = true;
    notifyListeners();
  }

  /// Start recording audio for up to 1 minute
  Future<void> startRecording() async {
    // Check if already recorded today
    if (_hasRecordedToday) {
      _state = RecordingState.error;
      _errorMessage = 'You have already recorded today. Come back tomorrow!';
      notifyListeners();
      return;
    }

    try {
      // Check permission
      if (!await _audioRecorder.hasPermission()) {
        _state = RecordingState.error;
        _errorMessage = 'Microphone permission denied';
        notifyListeners();
        return;
      }

      // Get the temporary directory to store the audio file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioFilePath = '${directory.path}/recording_$timestamp.m4a';

      // Configure and start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: _audioFilePath!,
      );

      _state = RecordingState.recording;
      _remainingSeconds = 60;
      _transcribedText = '';
      _errorMessage = '';
      notifyListeners();

      // Start countdown timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _remainingSeconds--;
        notifyListeners();

        if (_remainingSeconds <= 0) {
          stopRecording();
        }
      });
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  /// Stop recording and trigger transcription
  Future<void> stopRecording() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      final path = await _audioRecorder.stop();
      _audioFilePath = path;

      if (path != null && await File(path).exists()) {
        _state = RecordingState.processing;
        notifyListeners();

        // Transcribe the audio
        await _transcribeAudio(path);
      } else {
        _state = RecordingState.error;
        _errorMessage = 'Recording file not found';
        notifyListeners();
      }
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'Failed to stop recording: $e';
      notifyListeners();
    }
  }

  /// Transcribe audio file to text using the FastAPI backend
  Future<void> _transcribeAudio(String filePath) async {
    try {
      final transcription = await _transcriptionService.transcribeAudio(
        filePath,
        _userId,
      );
      _transcribedText = transcription;
      _state = RecordingState.completed;

      // Mark today as recorded
      await _markTodayAsRecorded();

      notifyListeners();
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'Transcription failed: $e';
      notifyListeners();
    }
  }

  /// Reset the provider to initial state
  void reset() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _state = RecordingState.idle;
    _transcribedText = '';
    _errorMessage = '';
    _remainingSeconds = 60;
    notifyListeners();
  }

  /// Reset the daily recording limit to allow recording again
  Future<void> resetDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_recording_date');
    _hasRecordedToday = false;
    reset();
    notifyListeners();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}
