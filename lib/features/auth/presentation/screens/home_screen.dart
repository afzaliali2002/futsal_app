import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/screens/tabbed_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen acts as a gateway to the main tabbed interface.
    return const TabbedHomeScreen();
  }
}
