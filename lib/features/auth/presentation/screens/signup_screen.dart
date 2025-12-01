
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../view_models/sign_up_view_model.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignUpViewModel(
        context.read<AuthRepository>(),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Consumer<SignUpViewModel>(
              builder: (context, viewModel, child) {
                return ListView(
                  padding: const EdgeInsets.only(top: 60, bottom: 40),
                  children: [
                    // Soccer Ball Logo
                    Center(
                      child: Image.asset(
                        'assets/images/soccer_ball.png',
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'ثبت‌نام',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'حساب کاربری خود را ایجاد کنید',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email
                    TextField(
                      textAlign: TextAlign.right,
                      onChanged: viewModel.setEmail,
                      decoration: InputDecoration(
                        labelText: 'ایمیل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextField(
                      textAlign: TextAlign.right,
                      obscureText: true,
                      onChanged: viewModel.setPassword,
                      decoration: InputDecoration(
                        labelText: 'رمز عبور',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.visibility_off),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password
                    TextField(
                      textAlign: TextAlign.right,
                      obscureText: true,
                      onChanged: viewModel.setConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'تکرار رمز عبور',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isValid
                            ? () => viewModel.signUp(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('ثبت‌نام'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'یا',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Google Sign Up
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/images/google_logo.png',
                        height: 20,
                      ),
                      label: const Text('گوگل'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Already have account?
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login'); // Go back to Login
                            },
                            child: Text(
                              'ورود',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'قبلاً حساب دارید؟',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}


