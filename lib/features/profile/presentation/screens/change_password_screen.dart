import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text('انجام شد')]),
        content: const Text('رمز عبور با موفقیت تغییر کرد.'),
        actions: [ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('باشه'))],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 10), Text('خطا')]),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(BuildContext scaffoldContext) async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final navigator = Navigator.of(scaffoldContext);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('کاربر وارد نشده است یا ایمیل ندارد.');
      }

      // Re-authenticate the user for security
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(cred);

      // If re-authentication is successful, change the password
      await user.updatePassword(_newPasswordController.text);

      // Show success message and navigate back
      await _showSuccessDialog(scaffoldContext);
      navigator.pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = 'رمز عبور فعلی شما اشتباه است.';
      } else if (e.code == 'weak-password') {
          errorMessage = 'رمز عبور جدید شما ضعیف است. لطفاً از رمز قوی‌تری استفاده کنید.';
      } else {
          errorMessage = e.message ?? 'یک خطای احراز هویت رخ داد.';
      }
      _showErrorDialog(scaffoldContext, errorMessage);
    } catch (e) {
      _showErrorDialog(scaffoldContext, 'یک خطای غیرمنتظره رخ داد. لطفاً اتصال اینترنت خود را بررسی کنید.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغییر رمز عبور'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Builder(
        builder: (scaffoldContext) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Current Password
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: !_currentPasswordVisible,
                    decoration: _inputDecoration(
                      labelText: 'رمز عبور فعلی',
                      prefixIcon: Icons.lock_outline,
                      isVisible: _currentPasswordVisible,
                      onToggleVisibility: () => setState(() => _currentPasswordVisible = !_currentPasswordVisible),
                    ),
                    validator: (value) => value!.isEmpty ? 'لطفاً رمز عبور فعلی را وارد کنید' : null,
                  ),
                  const SizedBox(height: 20),
                  // New Password
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_newPasswordVisible,
                    decoration: _inputDecoration(
                      labelText: 'رمز عبور جدید',
                      prefixIcon: Icons.lock,
                      isVisible: _newPasswordVisible,
                      onToggleVisibility: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'لطفاً رمز عبور جدید را وارد کنید';
                      if (value.length < 6) return 'رمز عبور باید حداقل ۶ کاراکتر باشد';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Confirm New Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    decoration: _inputDecoration(
                      labelText: 'تکرار رمز عبور جدید',
                      prefixIcon: Icons.lock_person_outlined,
                      isVisible: _confirmPasswordVisible,
                      onToggleVisibility: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) return 'رمزهای عبور مطابقت ندارند';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  // Save Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : () => _changePassword(scaffoldContext),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('ذخیره تغییرات', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: IconButton(
        icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggleVisibility,
      ),
    );
  }
}
