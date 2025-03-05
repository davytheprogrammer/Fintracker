import 'package:flutter/material.dart';
import '../../main.dart';

class AppearancePage extends StatefulWidget {
  @override
  _AppearancePageState createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  // Use the themeNotifier from MyApp to manage the theme state
  ThemeMode _themeMode = MyApp.themeNotifier.value;

  @override
  Widget build(BuildContext context) {
    // Get the current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "App Appearance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // Use theme-aware colors
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(
          // Add subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ]
                : [
              Colors.grey[100]!,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Theme Mode",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24),

              // Theme options
              _buildThemeOption(
                context: context,
                title: "Light Mode",
                subtitle: "Classic bright appearance",
                icon: Icons.light_mode,
                value: ThemeMode.light,
              ),
              _buildThemeOption(
                context: context,
                title: "Dark Mode",
                subtitle: "Easier on the eyes in low light",
                icon: Icons.dark_mode,
                value: ThemeMode.dark,
              ),
              _buildThemeOption(
                context: context,
                title: "System Mode",
                subtitle: "Follows your device settings",
                icon: Icons.settings_system_daydream,
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode value,
  }) {
    final isSelected = _themeMode == value;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
      BoxShadow(
      color: theme.shadowColor.withOpacity(0.1),
      blurRadius: 8,
      offset: Offset(0, 2),
      ),
      ],
    ),
    child: Material(
    color: Colors.transparent,
    child: InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
    setState(() {
    _themeMode = value;
    MyApp.themeNotifier.value = _themeMode; // Update the theme
    });
    },
    child: Padding(
    padding: EdgeInsets.all(16),
    child: Row(
    children: [
    Icon(
    icon,
    size: 28,
    color: isSelected
    ? theme.colorScheme.primary
        : theme.iconTheme.color,
    ),
    SizedBox(width: 16),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    title,
    style: theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: isSelected
    ? theme.colorScheme.primary
        : theme.textTheme.titleMedium?.color,
    ),
    ),
    SizedBox(height: 4),
    Text(
    subtitle,
    style: theme.textTheme.bodyMedium?.copyWith(
    color: theme.textTheme.bodySmall?.color,
    ),
    ),
    ],
    ),
    ),
    if (isSelected)
    Icon(
    Icons.check_circle,
    color: theme.colorScheme.primary,
    ),
    ],
    ),
    ),
    ),
    ),
    );
  }
}