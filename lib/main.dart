import 'package:flutter/material.dart';
import 'package:Finspense/models/the_user.dart';
import 'package:Finspense/services/auth.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'screens/home_screen/home.dart';
import 'wrapper.dart';
import 'package:firebase_core/firebase_core.dart';

class Routes {
  static const String app = '/app';
  static const String wrapper = '/wrapper';
  static const String home = '/home';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Changed default to light mode

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light); // Changed default to light mode

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return StreamProvider<TheUser?>.value(
      value: AuthService().user,
      initialData: null,
      catchError: (_, __) => null,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, ThemeMode currentMode, _) {
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: Routes.wrapper,
            routes: {
              Routes.app: (context) => const App(),
              Routes.wrapper: (context) => const Wrapper(),
              Routes.home: (context) => HomePage(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.grey[200],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey[900],
  scaffoldBackgroundColor: Colors.blueGrey[900],
  cardColor: Colors.blueGrey[800],
  colorScheme: ColorScheme.dark(
    primary: Colors.blueAccent,
    secondary: Colors.blueAccent[200]!,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blueGrey[900],
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blueAccent,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
  ),
);
