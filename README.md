# Finspense - Personal Finance Tracker

A sleek and powerful Flutter-based personal finance app that helps you track your expenses and income with ease.

## Screenshots

<p align="center">
  <img src="assets/WhatsApp Image 2026-04-03 at 1.32.35 PM.jpeg" width="200" alt="Screenshot 1" />
  <img src="assets/WhatsApp Image 2026-04-03 at 1.32.35 PM (1).jpeg" width="200" alt="Screenshot 2" />
  <img src="assets/WhatsApp Image 2026-04-03 at 1.32.36 PM.jpeg" width="200" alt="Screenshot 3" />
  <img src="assets/WhatsApp Image 2026-04-03 at 1.32.36 PM (1).jpeg" width="200" alt="Screenshot 4" />
  <img src="assets/WhatsApp Image 2026-04-03 at 1.32.36 PM (2).jpeg" width="200" alt="Screenshot 5" />
</p>

## Features

- Track Income & Expenses - Monitor your financial transactions with ease
- Visual Analytics - Beautiful charts and graphs to visualize your spending patterns
- Budget Management - Keep track of your budgets and spending limits
- Smart Notifications - Get timely reminders and alerts
- Location Tracking - Tag your transactions with location data
- PDF Reports - Generate and export detailed financial reports
- Firebase Authentication - Secure user authentication and cloud sync
- Modern UI - Clean, intuitive interface with smooth animations

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/finspense.git
   cd finspense
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your Android/iOS app to the Firebase project
   - Download and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Enable Firebase Authentication and Cloud Firestore

4. **Configure environment variables**
   ```bash
   # Create a .env file in the root directory
   # Add your Firebase config and other environment variables
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend and authentication
- [Provider](https://pub.dev/packages/provider) - State management
- [FL Chart](https://pub.dev/packages/fl_chart) - Beautiful charts
- [Google Fonts](https://pub.dev/packages/google_fonts) - Typography
- [Flutter Map](https://pub.dev/packages/flutter_map) - Location features
- [PDF](https://pub.dev/packages/pdf) - PDF generation

## Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.15.6
  provider: ^6.0.5
  fl_chart: 0.66.2
  flutter_map: ^6.1.0
  pdf: ^3.11.3
  google_fonts: ^6.2.1
  shared_preferences: ^2.0.8
  awesome_notifications: ^0.10.1
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── screens/               # App screens
├── widgets/               # Reusable widgets
├── services/              # Business logic and services
├── providers/             # State management
└── utils/                 # Utility functions and helpers
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**davytheprogrammer**
- GitHub: [@davytheprogrammer](https://github.com/davytheprogrammer)

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who helped make this project better

---

<p align="center">
  Made with ❤️ for better financial management
</p>
