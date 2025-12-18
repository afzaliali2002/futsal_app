import 'dart:async';
import 'package:flutter/material.dart';
import 'package:futsal_app/features/notification/data/models/notification_model.dart';
import 'package:futsal_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:futsal_app/features/notification/domain/usecases/get_notifications_use_case.dart';

class NotificationViewModel extends ChangeNotifier {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final NotificationRepository _notificationRepository;

  NotificationViewModel(this._getNotificationsUseCase, this._notificationRepository);

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _getNotificationsUseCase(userId);
  }

  Stream<int> getUnreadNotificationsCount(String userId) {
    return _notificationRepository.getUnreadNotificationsCount(userId);
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationRepository.markAsRead(userId, notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _notificationRepository.markAllAsRead(userId);
  }
}
