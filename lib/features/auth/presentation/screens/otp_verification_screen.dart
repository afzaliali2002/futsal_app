import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;

  const OtpVerificationScreen({super.key, required this.verificationId});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onVerifyPressed() async {
    if (_otpController.text.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = context.read<AuthRepository>();
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );
      await authRepository.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred.';
        if (e is FirebaseAuthException) {
          errorMessage = e.message ?? 'Failed to verify OTP.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تایید کد')), 
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'کد تاییدی ارسال شده به شماره موبایل خود را وارد کنید.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'کد ۶ رقمی'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onVerifyPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تایید و ورود'),
            ),
          ],
        ),
      ),
    );
  }
}
