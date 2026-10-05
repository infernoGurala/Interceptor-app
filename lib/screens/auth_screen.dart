import 'package:flutter/material.dart';

/// Legacy AuthScreen replaced by local-first architecture.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/home');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
