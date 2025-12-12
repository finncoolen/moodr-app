import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const purple = Color(0xFF9B87F5);
  static final purpleDark = Colors.deepPurple.shade400;
  static final purpleLight = Colors.purple.shade300;

  // Accents
  static const yellow = Color(0xFFFDB43C); // Ideas
  static const pink = Color(0xFFFF6B9D); // Feelings
  static const green = Color(0xFF4ADE80); // Actions
  static const red = Color(0xFFFF6B6B); // Recording

  // Status
  static const success = Color(0xFF7ED957);
  static const pending = Color(0xFFFDB43C); // Changed from red to amber
  static const completed = Color(0xFF7ED957);

  // Backgrounds
  static const gradientStart = Color(0xFFFFF5F5);
  static const gradientMid = Color(0xFFFFF9E5);
  static const gradientEnd = Color(0xFFF5F5FF);

  // Recording button states
  static final recordingButtonIdle = purpleDark;
  static const recordingButtonRecording = red;
  static const recordingButtonProcessing = purple;
  static const recordingButtonCompleted = Color(
    0xFFE8D5FF,
  ); // Pale pinky purple
  static const recordingButtonCompletedShadow = Color(0xFFD4B5FF);
}
