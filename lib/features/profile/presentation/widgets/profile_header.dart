import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        const SizedBox(height: 15),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              color: user.isOnline ? Colors.green : Colors.red,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              user.isOnline ? "آنلاین" : "آفلاین",
              style: TextStyle(
                color: user.isOnline ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
