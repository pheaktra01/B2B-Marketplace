import '../models/conversation_model.dart';

final List<Conversation> mockConversations = [
  Conversation(
    name: 'Green Valley Organics',
    message: 'The heirloom tomatoes are ready fo...',
    time: '10:45 AM',
    unreadCount: 2,
    isOnline: true,
    avatarUrl:
        'https://i.pinimg.com/736x/cb/bc/ef/cbbceffe703ba2c8918132599130fdec.jpg',
  ),

  Conversation(
    name: 'Bistro 44 - Procurement',
    message:
        'Invoice #8842 has been settled.\nThank you for the quick delivery.',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: false,
    avatarUrl: 'https://via.placeholder.com/150',
  ),

  Conversation(
    name: 'Chef Elena Rossi',
    message:
        'Can we double the order of microgreens for Friday\'s event?',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: true,
    avatarUrl: 'https://via.placeholder.com/150',
  ),
];