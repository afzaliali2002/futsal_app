import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = context.read<AuthRepository>();
      await authRepository.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = 'یک خطای ناشناخته رخ داد.';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'این ایمیل قبلاً در سیستم ثبت شده است.';
        } else if (e.code == 'network-request-failed') {
          errorMessage = 'خطا در اتصال به اینترنت. لطفاً اتصال خود را بررسی کنید.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'رمز عبور ضعیف است. لطفاً رمز قوی‌تری انتخاب کنید.';
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

  Future<void> _onGoogleSignUpPressed() async {
    if (_isGoogleLoading) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final authRepository = context.read<AuthRepository>();
      await authRepository.signUpWithGoogle();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
      }

    } catch (e, s) {
      if (mounted) {
        String errorMessage;

        print('----------- GOOGLE SIGN-UP ERROR -----------');
        print('Error Type: ${e.runtimeType}');
        print('Error: $e');
        print('Stack Trace: $s');
        print('------------------------------------------');

        if (e is FirebaseAuthException) {
            switch (e.code) {
              case 'account-exists-with-different-credential':
                errorMessage = 'حسابی با این ایمیل قبلاً از طریق دیگری ثبت شده است.';
                break;
              case 'user-disabled':
                errorMessage = 'این حساب کاربری غیرفعال شده است.';
                break;
              default:
                errorMessage = 'خطایی در ثبت نام با گوگل رخ داد. کد خطا: ${e.code}';
            }
        } else if (e is PlatformException) {
            errorMessage = 'خطای پلتفرم در ثبت نام با گوگل: ${e.message} (کد: ${e.code})';
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
        appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Image.asset('assets/images/soccer_ball.png', height: 80),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ایجاد حساب کاربری',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'نام کامل'),
                      validator: (value) =>
                          value!.isEmpty ? 'لطفاً نام خود را وارد کنید' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'ایمیل'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty || !value.contains('@')
                          ? 'لطفاً ایمیل معتبری وارد کنید'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'رمز عبور'),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? 'رمز عبور باید حداقل ۶ کاراکتر باشد'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'تکرار رمز عبور'),
                      obscureText: true,
                      validator: (value) =>
                          value != _passwordController.text ? 'رمزهای عبور مطابقت ندارند' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _onSignUpPressed,
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
                          : const Text('ثبت نام'),
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
                      onPressed: _onGoogleSignUpPressed,
                      icon: _isGoogleLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset('assets/images/google_logo.png', height: 20),
                      label: const Text('ثبت نام با گوگل'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('قبلاً حساب کاربری دارید؟'),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ورود'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
