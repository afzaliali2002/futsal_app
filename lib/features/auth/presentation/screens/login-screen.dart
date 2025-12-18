import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';
import 'otp_verification_screen.dart';

enum LoginType { email, phone }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final LoginType _loginType = LoginType.email; // Keep it on email login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authRepository = context.read<AuthRepository>();

    // This part is now simplified as we only support email login from this screen.
    try {
      await authRepository.login(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'یک خطای ناشناخته رخ داد.';
        if (e.code == 'user-not-found') {
          errorMessage = 'حسابی با این ایمیل وجود ندارد.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'رمز عبور وارد شده اشتباه است.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'ایمیل یا رمز عبور وارد شده اشتباه است.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onGoogleSignInPressed() async {
    if (_isGoogleLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final authRepository = context.read<AuthRepository>();
      await authRepository.signOutFromGoogle();
      await authRepository.signInWithGoogle();

      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }
    } catch (e, s) {
      if (mounted) {
        String errorMessage;

        print('----------- GOOGLE SIGN-IN ERROR -----------');
        print('Error Type: ${e.runtimeType}');
        print('Error: $e');
        print('Stack Trace: $s');
        print('------------------------------------------');

        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage =
                  'حسابی با این ایمیل گوگل وجود ندارد. لطفاً ابتدا ثبت نام کنید.';
              break;
            case 'account-exists-with-different-credential':
              errorMessage =
                  'این حساب با روش دیگری ثبت شده است. لطفاً با ایمیل و رمز عبور وارد شوید.';
              break;
            default:
              errorMessage = 'خطایی در ورود با گوگل رخ داد. کد خطا: ${e.code}';
          }
        } else if (e is PlatformException) {
          errorMessage = 'خطای پلتفرم در ورود با گوگل: ${e.message} (کد: ${e.code})';
        } else {
          errorMessage = 'یک خطای غیرمنتظره رخ داد: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Image.asset('assets/images/soccer_ball.png', height: 100),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'خوش آمدید!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // The form will always be for email and password
                  Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'ایمیل'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'لطفاً ایمیل خود را وارد کنید' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'رمز عبور'),
                        obscureText: true,
                        validator: (value) => value!.isEmpty
                            ? 'لطفاً رمز عبور خود را وارد کنید'
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('ورود'), // Button text is always 'ورود'
                  ),
                  const SizedBox(height: 16),
                  // Replaced TextButton with a non-interactive Text widget
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'ورود با شماره موبایل',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue), // Style to look like a link
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('یا', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _onGoogleSignInPressed,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Image.asset('assets/images/google_logo.png', height: 20),
                    label: const Text('ورود با گوگل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('حساب کاربری ندارید؟'),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text('ثبت نام'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
