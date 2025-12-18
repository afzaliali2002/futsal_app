import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal_app/core/services/cloudinary_service.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../../data/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _retrieveLostImageData();
    }
  }

  Future<void> _retrieveLostImageData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _avatarImage = File(response.file!.path);
      });
    }
  }

  Future<void> _pickImage() async {
    final photosStatus = await Permission.photos.status;
    if (!mounted) return;

    if (photosStatus.isGranted || photosStatus.isLimited) {
      try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
        if (pickedFile != null) {
          setState(() {
            _avatarImage = File(pickedFile.path);
          });
        }
      } on PlatformException catch (e) {
        if (mounted) {
          _showErrorDialog('خطا در انتخاب تصویر: ${e.message}');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('خطایی ناشناخته در هنگام باز کردن گالری رخ داد.');
        }
      }
    } else {
      final newStatus = await Permission.photos.request();
      if (!mounted) return;
      if (newStatus.isGranted || newStatus.isLimited) {
        await _pickImage();
      } else {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دسترسی به گالری رد شد'),
        content: const Text('برای انتخاب عکس، لطفاً از تنظیمات گوشی دسترسی لازم را به برنامه بدهید.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('باشه')),
          ElevatedButton(onPressed: () { openAppSettings(); Navigator.of(context).pop(); }, child: const Text('رفتن به تنظیمات')),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);

    bool emailChanged = false;

    try {
      final localUser = widget.user;
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        throw Exception('شما وارد حساب کاربری خود نشده‌اید. لطفاً دوباره وارد شوید.');
      }
      if (localUser.uid != firebaseUser.uid) {
        throw Exception('اطلاعات کاربری شما یافت نشد. لطفاً دوباره وارد شوید.');
      }

      String? newAvatarUrl;

      if (_avatarImage != null) {
        final response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _avatarImage!.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'user_avatars/${firebaseUser.uid}',
          ),
        );
        newAvatarUrl = response.secureUrl;
      }

      if (_emailController.text.trim() != localUser.email) {
        emailChanged = true;
        await firebaseUser.verifyBeforeUpdateEmail(_emailController.text.trim());
      }

      final updatedData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        if (newAvatarUrl != null) 'avatarUrl': newAvatarUrl,
        'modifiedAt': FieldValue.serverTimestamp(),
        'modifiedBy': firebaseUser.uid,
      };

      if (localUser.createdAt == null) {
        updatedData['createdAt'] = FieldValue.serverTimestamp();
        updatedData['createdBy'] = firebaseUser.uid;
      }

      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update(updatedData);

      if (!mounted) return;

      await _showSuccessDialog(emailChanged);
      Navigator.of(context).pop();

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'خطایی در فرآیند احراز هویت رخ داد.';
      if (e.code == 'requires-recent-login') {
        final didReauthenticate = await _showReauthenticationDialog() ?? false;
        if (didReauthenticate) {
          await _onSave();
          return;
        }
        errorMessage = 'برای تغییر ایمیل، باید مجدداً وارد شوید. لطفاً رمز عبور خود را وارد کنید.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'این ایمیل قبلاً توسط حساب دیگری استفاده شده است.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'رمز عبور فعلی شما اشتباه است.';
      }
      _showErrorDialog(errorMessage);
    } on FirebaseException catch (e) {
        if (!mounted) return;
        if (e.code == 'object-not-found') {
          _showErrorDialog('خطا در آپلود تصویر. ممکن است فضای ذخیره‌سازی پروژه شما فعال نباشد یا قوانین امنیتی آن اجازه آپلود را نمی‌دهد. لطفاً تنظیمات پروژه خود را بررسی کنید.');
        } else {
          _showErrorDialog('خطای سرویس: ${e.message}');
        }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().startsWith('Exception: ') ? e.toString().substring(11) : e.toString();
      _showErrorDialog(message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(bool emailWasChanged) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text('انجام شد')]),
        content: Text(emailWasChanged
            ? 'پروفایل شما با موفقیت به روز شد. لطفاً ایمیل خود را برای تایید آدرس جدید بررسی کنید.'
            : 'پروفایل شما با موفقیت به روز شد.'),
        actions: [ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('باشه'))],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(children: [Icon(Icons.error_outline, color: Colors.red), SizedBox(width: 10), Text('خطا')]),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showReauthenticationDialog() {
    final passwordController = TextEditingController();
    bool isAuthenticating = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('تأیید هویت'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('برای ادامه، لطفاً رمز عبور خود را دوباره وارد کنید.'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'رمز عبور'),
                    enabled: !isAuthenticating,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isAuthenticating ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: isAuthenticating
                      ? null
                      : () async {
                          setStateInDialog(() => isAuthenticating = true);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null || user.email == null) {
                            if(mounted) Navigator.of(dialogContext).pop(false);
                            _showErrorDialog('کاربر یافت نشد.');
                            return;
                          }
                          final cred = EmailAuthProvider.credential(email: user.email!, password: passwordController.text);
                          try {
                            await user.reauthenticateWithCredential(cred);
                             if(mounted)  Navigator.of(dialogContext).pop(true);
                          } on FirebaseAuthException catch (e) {
                             if(mounted) Navigator.of(dialogContext).pop(false);
                            final message = e.code == 'wrong-password' ? 'رمز عبور اشتباه است' : 'خطا در تأیید هویت';
                            _showErrorDialog(message);
                          }
                        },
                  child: isAuthenticating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3))
                      : const Text('تأیید'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ویرایش پروفایل'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 130, height: 130,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircleAvatar(
                                backgroundImage: _avatarImage != null
                                    ? FileImage(_avatarImage!)
                                    : (widget.user.avatarUrl.isNotEmpty
                                        ? NetworkImage(widget.user.avatarUrl)
                                        : const AssetImage('assets/images/default_avatar.png')) as ImageProvider,
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: Material(
                                  color: theme.primaryColor, shape: const CircleBorder(), elevation: 2,
                                  child: InkWell(
                                    onTap: _pickImage, customBorder: const CircleBorder(),
                                    child: const Padding(padding: const EdgeInsets.all(8.0), child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(labelText: 'نام کامل', prefixIcon: Icon(Icons.person_outline), border: UnderlineInputBorder()),
                                  validator: (value) => value!.isEmpty ? 'لطفاً نام خود را وارد کنید' : null,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(labelText: 'ایمیل', prefixIcon: Icon(Icons.email_outlined), border: UnderlineInputBorder()),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) => (value!.isEmpty || !value.contains('@')) ? 'لطفاً ایمیل معتبری وارد کنید' : null,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  initialValue: widget.user.role.translate(),
                                  enabled: false,
                                  decoration: const InputDecoration(labelText: 'نقش کاربری', prefixIcon: Icon(Icons.verified_user_outlined), border: UnderlineInputBorder()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('ذخیره تغییرات', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
