import '../models/conversation_model.dart';

final List<Conversation> mockConversations = [
  Conversation(
    name: 'Green Valley Organics',
    message: 'ប៉េងប៉ោះបុរាណត្រូវបានរួចរាល់សម្រាប់ច្រូតហើយ...',
    time: '10:45 AM',
    unreadCount: 2,
    isOnline: true,
    avatarUrl: 'assets/mokoto.jpg',
  ),

  Conversation(
    name: 'Bistro 44 - Procurement',
    message: 'វិក័យប័ត្រ #8842 ត្រូវបានបង់រួចរាល់។\nសូមអរគុណចំពោះការដឹកជញ្ជូនដែលលឿន។',
    time: 'ម្សិលមិញ',
    unreadCount: 0,
    isOnline: false,
    avatarUrl: 'assets/joker.png',
  ),

  Conversation(
    name: 'Chef Elena Rossi',
    message: 'តើយើងអាចបង្កើនការបញ្ជាទិញនៃ microgreens សម្រាប់ព្រឹត្តិការណ៍ថ្ងៃសុក្របានទេ?',
    time: 'ម្សិលមិញ',
    unreadCount: 0,
    isOnline: true,
    avatarUrl: 'assets/junpei.jpg',
  ),
];