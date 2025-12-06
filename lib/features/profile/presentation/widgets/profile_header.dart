import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String avatar = user.avatarUrl.trim();
    final String joinDate = user.createdAt != null
        ? DateFormat.yMMMMd('fa_IR').format(user.createdAt!)
        : 'تاریخ عضویت نامشخص';

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundImage: avatar.isNotEmpty
                ? NetworkImage(avatar)
                : const AssetImage("assets/images/default_avatar.png") as ImageProvider,
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(height: 15),

          //Name
          Text(
            user.name.isNotEmpty ? user.name : "نام ثبت نشده",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          /// Email
          Text(
            user.email.isNotEmpty ? user.email : "ایمیل ثبت نشده",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),

          /// Join Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "عضو از $joinDate",
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
