import '../models/conversation_model.dart';

final List<Conversation> mockConversations = [
  Conversation(
    name: 'Green Valley Organics',
    message: 'The heirloom tomatoes are ready for harvest...',
    time: '10:45 AM',
    unreadCount: 2,
    isOnline: true,
    avatarUrl: 'assets/mokoto.jpg',
  ),

  Conversation(
    name: 'Bistro 44 - Procurement',
    message: 'Invoice #8842 has been paid.\nThank you for the quick delivery.',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: false,
    avatarUrl: 'assets/joker.png',
  ),

  Conversation(
    name: 'Chef Elena Rossi',
    message: 'Can we increase the microgreens order for Friday\'s event?',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: true,
    avatarUrl: 'assets/junpei.jpg',
  ),
];