import 'package:flutter/material.dart';
import 'package:futsal_app/features/profile/data/models/user_role.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String avatar = user.avatarUrl.trim();
    final String joinDate;

    if (user.createdAt != null) {
      final Jalali jalaliDate = Jalali.fromDateTime(user.createdAt!);
      final f = jalaliDate.formatter;
      joinDate = '${f.yyyy} ${f.mN} ${f.d}';
    } else {
      joinDate = 'تاریخ عضویت نامشخص';
    }

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

          /// User Role
          Text(
            user.role.translate(),
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          /// Join Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "عضو از $joinDate",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
