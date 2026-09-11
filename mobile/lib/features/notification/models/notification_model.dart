class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? referenceId;
  final String? referenceType;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.referenceId,
    required this.referenceType,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,
      referenceId: json['referenceId']?.toString(),
      referenceType: json['referenceType']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId,
      referenceType: referenceType,
      createdAt: createdAt,
    );
  }

  String get category {
    final lower = type.toLowerCase();
    if (lower.contains('order')) return 'orders';
    if (lower.contains('message') || lower.contains('chat')) return 'messages';
    if (lower.contains('payment')) return 'payments';
    if (lower.contains('product') || lower.contains('stock') || lower.contains('inventory')) return 'products';
    if (lower.contains('account') || lower.contains('security') || lower.contains('password') || lower.contains('login') || lower.contains('profile')) return 'account';
    return 'system';
  }

  bool get isOrder => category == 'orders';
  bool get isChat => category == 'messages';
  bool get isPayment => category == 'payments';
  bool get isProduct => category == 'products';
  bool get isAccount => category == 'account';
  bool get isSystem => category == 'system';
}
