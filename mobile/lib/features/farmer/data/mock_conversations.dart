import '../models/conversation_model.dart';

final List<Conversation> mockConversations = [
  Conversation(
    name: 'Green Valley Organics',
    message: 'The heirloom tomatoes are ready fo...',
    time: '10:45 AM',
    unreadCount: 2,
    isOnline: true,
    avatarUrl:
        'assets/mokoto.jpg',
  ),

  Conversation(
    name: 'Bistro 44 - Procurement',
    message:
        'Invoice #8842 has been settled.\nThank you for the quick delivery.',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: false,
    avatarUrl: 'assets/joker.png',
  ),

  Conversation(
    name: 'Chef Elena Rossi',
    message:
        'Can we double the order of microgreens for Friday\'s event?',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: true,
    avatarUrl: 'assets/junpei.jpg',
  ),
];