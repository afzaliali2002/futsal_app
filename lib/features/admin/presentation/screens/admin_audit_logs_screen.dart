import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../view_models/admin_view_model.dart';
// Import models to check types/find names if needed
import 'package:futsal_app/features/profile/data/models/user_model.dart';
import 'package:futsal_app/features/futsal/domain/entities/futsal_field.dart';

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminViewModel>().fetchAuditLogs());
  }

  String _toPersian(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const fa = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    var res = input;
    for (int i = 0; i < en.length; i++) {
      res = res.replaceAll(en[i], fa[i]);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminViewModel>();
    final logs = vm.auditLogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لاگ‌های امنیتی'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.fetchAuditLogs(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await vm.fetchAuditLogs(),
        child: logs.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('هیچ لاگی ثبت نشده است', style: TextStyle(color: Colors.grey))),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: logs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final rawAction = log['action'] ?? 'Unknown';
                  final admin = log['adminId'] ?? 'System';
                  
                  DateTime? time;
                  if (log['timestamp'] is Timestamp) {
                    time = (log['timestamp'] as Timestamp).toDate();
                  } else if (log['timestamp'] is String) {
                    time = DateTime.tryParse(log['timestamp']);
                  }

                  final title = _getPersianTitle(rawAction);
                  final description = _getPersianDescription(rawAction);
                  final iconData = _getActionIcon(rawAction);
                  final color = _getActionColor(rawAction);
                  final targetId = _extractId(rawAction);
                  
                  // Try to find the name of the target
                  final targetName = _resolveTargetName(targetId, rawAction, vm);

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showLogDetails(context, title, description, rawAction, admin, time, targetId, targetName),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconData, color: color, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Show Name instead of generic description if available
                                  Text(
                                    targetName != null ? 'مورد: $targetName' : description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (time != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDateShort(time),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    _formatTime(time),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showLogDetails(BuildContext context, String title, String description, String rawAction, String admin, DateTime? time, String targetId, String? targetName) {
    // Clean up raw action for display
    String readableSystemOrder = rawAction;
    if (rawAction.contains('Updated Role')) {
       readableSystemOrder = 'تغییر نقش کاربر به: ${_extractRole(rawAction)}';
    } else if (rawAction.contains('Approved Ground')) {
       readableSystemOrder = 'تایید وضعیت زمین';
    } else if (rawAction.contains('Rejected Ground')) {
       readableSystemOrder = 'رد درخواست زمین';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handlebar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getActionColor(rawAction).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getActionIcon(rawAction), color: _getActionColor(rawAction), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 40),
              
              _detailRow(Icons.access_time, 'زمان ثبت', time != null ? _formatTimeFull(time) : 'نامشخص'),
              _detailRow(Icons.admin_panel_settings_outlined, 'ادمین مسئول', admin),
              
              // Show Target Name if available
              if (targetName != null)
                _detailRow(Icons.person_pin_circle_outlined, 'نام مورد نظر', targetName),

              // Show cleaner system order
              _detailRow(Icons.terminal, 'عملیات', readableSystemOrder),
              
              if (targetId.isNotEmpty)
                _detailRow(
                  Icons.fingerprint, 
                  'شناسه سیستمی (ID)', 
                  targetId, 
                  isCopyable: true,
                  isCode: true,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: targetId));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شناسه کپی شد')));
                    Navigator.pop(context);
                  }
                ),
                
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('بستن', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to find name from ID
  String? _resolveTargetName(String id, String rawAction, AdminViewModel vm) {
    if (id.isEmpty) return null;
    
    // Check for User
    if (rawAction.contains('User')) {
      try {
        final user = vm.users.firstWhere((u) => u.uid == id);
        return user.name;
      } catch (_) {
        return 'کاربر حذف شده / یافت نشد';
      }
    }
    
    // Check for Ground
    if (rawAction.contains('Ground')) {
       try {
        final ground = vm.grounds.firstWhere((g) => g.id == id);
        return ground.name;
       } catch (_) {
         return 'زمین حذف شده / یافت نشد';
       }
    }
    
    return null;
  }
  
  String _extractRole(String raw) {
    // raw: "Updated Role User: ... to UserRole.groundOwner"
    if (raw.contains('groundOwner')) return 'مالک زمین';
    if (raw.contains('admin')) return 'ادمین';
    if (raw.contains('user')) return 'کاربر عادی';
    return 'نامشخص';
  }

  Widget _detailRow(IconData icon, String label, String value, {bool isCopyable = false, bool isCode = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          value, 
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.w500,
                            fontFamily: isCode ? 'Courier' : null,
                            color: isCode ? Colors.grey[800] : Colors.black87,
                          ),
                        ),
                      ),
                      if (isCopyable) 
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.copy, size: 16, color: Colors.blue),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep existing helpers: _getPersianTitle, _getPersianDescription, _getActionIcon, _getActionColor, _extractId, date formatters)
  
  String _getPersianTitle(String raw) {
    if (raw.contains('Approved Ground')) return 'تایید زمین';
    if (raw.contains('Rejected Ground')) return 'رد زمین';
    if (raw.contains('Deleted Ground')) return 'حذف زمین';
    if (raw.contains('Deleted User')) return 'حذف کاربر';
    if (raw.contains('Blocked User')) return 'مسدودسازی کاربر';
    if (raw.contains('Updated Role')) return 'تغییر نقش کاربر';
    return 'عملیات سیستمی';
  }
  
  String _getPersianDescription(String raw) {
    if (raw.contains('Approved Ground')) return 'یک زمین جدید تایید و فعال شد';
    if (raw.contains('Rejected Ground')) return 'درخواست ثبت زمین رد شد';
    if (raw.contains('Deleted Ground')) return 'یک زمین از سیستم حذف شد';
    if (raw.contains('Deleted User')) return 'حساب کاربری حذف گردید';
    if (raw.contains('Blocked User')) return 'دسترسی کاربر مسدود شد';
    if (raw.contains('Updated Role')) return 'سطح دسترسی کاربر تغییر کرد';
    return raw;
  }

  IconData _getActionIcon(String raw) {
    if (raw.contains('Approved')) return Icons.verified;
    if (raw.contains('Rejected')) return Icons.block;
    if (raw.contains('Deleted')) return Icons.delete_outline;
    if (raw.contains('Blocked')) return Icons.lock_clock;
    if (raw.contains('Updated Role')) return Icons.manage_accounts_outlined;
    return Icons.info_outline;
  }

  Color _getActionColor(String raw) {
    if (raw.contains('Approved')) return Colors.green;
    if (raw.contains('Rejected')) return Colors.red;
    if (raw.contains('Deleted')) return Colors.red;
    if (raw.contains('Blocked')) return Colors.orange;
    if (raw.contains('Updated Role')) return Colors.blue;
    return Colors.grey;
  }

  String _extractId(String raw) {
    final parts = raw.split(':');
    if (parts.length > 1) {
      var idPart = parts[1].trim();
      if (idPart.contains(' ')) {
        // e.g. "ID to Role"
        return idPart.split(' ').first;
      }
      return idPart;
    }
    return '';
  }

  String _formatDateShort(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return _toPersian('${j.year}/${j.month}/${j.day}');
  }

  String _formatTime(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return _toPersian('${j.hour}:${j.minute.toString().padLeft(2, '0')}');
  }

  String _formatTimeFull(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    final f = j.formatter;
    return _toPersian('${f.wN}، ${f.d} ${f.mN} ${f.yyyy} - ساعت ${j.hour}:${j.minute.toString().padLeft(2, '0')}');
  }
}
