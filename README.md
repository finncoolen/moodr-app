# Mindworm 🧠

**Your Daily Reflection Companion**

Mindworm is a voice-first journaling app that helps you capture your thoughts, feelings, and ideas through daily 60-second audio recordings. Using AI-powered analysis, your reflections are automatically transcribed and organized into actionable insights.

## ✨ Features

- **🎙️ Quick Voice Recording**: Record up to 60 seconds of daily reflection
- **🤖 AI-Powered Analysis**: Automatic transcription and insight extraction using OpenAI Whisper
- **📊 Structured Reports**: Your thoughts organized into:
  - 💡 Ideas - Creative thoughts and concepts
  - 💭 Feelings - Emotional states and moods
  - ✅ Reminders - Action items and to-dos
- **📈 Historical Tracking**: View your past reflections and track patterns over time
- **🔒 Secure & Private**: Authentication powered by Supabase with secure data storage
- **🎨 Beautiful UI**: Modern, clean interface with smooth animations

## 🚀 Getting Started

### Prerequisites

- Flutter 3.10.1 or higher
- Dart SDK
- iOS 12.0+ or Android API 21+
- Active internet connection

### Installation

1. Clone the repository:
```bash
git clone https://github.com/finncoolen/moodr-app.git
cd moodr-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment:
   - Update `lib/config/app_config.dart` with your Supabase credentials
   - Ensure backend API is running (see [moodr-api](https://github.com/finncoolen/moodr-api))

4. Run the app:
```bash
flutter run
```

## 🏗️ Architecture

### Tech Stack

- **Frontend**: Flutter 3.10.1 with Material Design 3
- **State Management**: Provider
- **Backend**: FastAPI (Python) - [Repository](https://github.com/finncoolen/moodr-api)
- **Authentication**: Supabase Auth
- **Database**: Supabase (PostgreSQL)
- **AI/ML**: OpenAI Whisper (transcription) & GPT (analysis)
- **Audio Recording**: `record` package
- **Storage**: `shared_preferences` for local data

### Project Structure

```
lib/
├── config/          # App configuration
├── models/          # Data models
├── providers/       # State management
│   ├── auth_provider.dart
│   ├── recording_provider.dart
│   └── reports_provider.dart
├── screens/         # UI screens
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── onboarding_screen.dart
│   ├── report_screen.dart
│   └── settings_screen.dart
├── services/        # API services
│   ├── recording_service.dart
│   └── transcription_service.dart
├── theme/           # Design system
│   ├── app_colors.dart
│   ├── app_spacing.dart
│   ├── app_text_styles.dart
│   └── app_shadows.dart
└── main.dart        # App entry point
```

## 🔧 Configuration

### Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Set up the following tables:
   - `users` (created automatically with auth)
   - `transcriptions` - stores audio transcriptions
   - `reports` - stores analyzed reflections
3. Configure Row Level Security (RLS) policies
4. Update `lib/config/app_config.dart` with your credentials

### Backend API

The app requires a running FastAPI backend for transcription and report generation. See the [moodr-api repository](https://github.com/finncoolen/moodr-api) for setup instructions.

API Endpoints:
- `POST /upload/audio/` - Upload audio for transcription
- `GET /recording/can-record-today` - Check daily recording status
- `GET /report/latest` - Get latest report
- `GET /report/latest/30days` - Get reports from last 30 days
- `PATCH /report/{id}` - Update report reminders

## 📱 App Flow

1. **Authentication**: Sign up or log in with email/password
2. **Onboarding**: First-time users see a 3-screen introduction
3. **Home Screen**: 
   - Daily recording status indicator
   - Record button (press to start/stop)
   - View reminders from recent reflections
4. **Recording**: 
   - Maximum 60 seconds per day
   - Real-time countdown timer
   - Automatic transcription on completion
5. **Reports**: View historical reflections with extracted insights
6. **Settings**: Manage account and view app info

## 🎨 Design System

- **Primary Color**: Purple (`#9B87F5`)
- **Accent Colors**: 
  - Pending: Amber (`#FDB43C`)
  - Success: Green (`#7ED957`)
  - Error: Red
- **Border Radius**: 16px standard
- **Typography**: System font with defined scale (h1-h4, body, caption)
- **Spacing**: 8px base unit (xs: 8, sm: 16, md: 24, lg: 32, xl: 48)

## 🔒 Privacy & Security

- All audio recordings are transmitted securely via HTTPS
- Recordings are processed and deleted from temporary storage
- User authentication via JWT tokens
- Data stored in Supabase with RLS policies
- No tracking or analytics (privacy-first approach)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is private and not licensed for public use.

## 👤 Author

**Finn Coolen**
- GitHub: [@finncoolen](https://github.com/finncoolen)

## 🙏 Acknowledgments

- OpenAI for Whisper and GPT APIs
- Supabase for backend infrastructure
- Flutter team for the amazing framework

---

**Built with ❤️ using Flutter**
