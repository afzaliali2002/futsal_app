import 'package:futsal_app/features/notification/data/models/notification_model.dart';
import 'package:futsal_app/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Stream<List<NotificationModel>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
