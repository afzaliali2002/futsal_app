
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(
        context.read<AuthRepository>(),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Consumer<LoginViewModel>(
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

                    // Welcome Back!
                    Text(
                      'دوباره خوش آمدید!',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'برای ادامهٔ رزرو زمین فوتسال، وارد شوید',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    TextField(
                      textDirection: TextDirection.rtl,
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

                    // Password Field
                    TextField(
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      onChanged: viewModel.setPassword,
                      obscureText: true,
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
                    const SizedBox(height: 32),

                    // Forgot Password? (aligned to LEFT in RTL)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'رمز عبور را فراموش کرده‌ام؟',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Log In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isValid
                            ? ()=> viewModel.login(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('ورود'),
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

                    // Google Sign In Button
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

                    // Sign Up Link (RTL order: "Sign Up" comes BEFORE text)
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'حساب کاربری ندارید؟',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            'ثبت‌نام',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
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
