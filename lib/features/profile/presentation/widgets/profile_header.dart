import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String avatar = user.avatarUrl.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(avatar)
                : const AssetImage("assets/images/default_avatar.png")
            as ImageProvider,
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(height: 15),

          /// Name
          Text(
            user.name.isNotEmpty ? user.name : "نام ثبت نشده",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// Email
          Text(
            user.email.isNotEmpty ? user.email : "ایمیل ثبت نشده",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          /// Online Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 14,
                color: user.isOnline ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                user.isOnline ? "آنلاین" : "آفلاین",
                style: TextStyle(
                  color: user.isOnline ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
