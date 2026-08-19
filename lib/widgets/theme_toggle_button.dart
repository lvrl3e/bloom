import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

/// Sun/moon icon button that flips [ThemeService]'s mode. Placed in every
/// tab's app bar so it's reachable no matter which screen is open.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    return IconButton(
      tooltip: themeService.isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(themeService.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => themeService.toggle(),
    );
  }
}
