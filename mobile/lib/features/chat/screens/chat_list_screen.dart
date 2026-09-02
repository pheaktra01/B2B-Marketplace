import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/farmer/data/mock_conversations.dart';
import 'package:mobile/features/farmer/models/conversation_model.dart';
import 'package:mobile/features/notification/screens/notifications_screen.dart';
import 'package:mobile/features/chat/widgets/conversation_card.dart';
import 'package:mobile/features/farmer/widgets/farmer_app_bar.dart';
import 'package:mobile/features/farmer/widgets/farmer_bottom_nav_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // ============================================================
  // STATE
  // ============================================================

  int _selectedCategoryIndex = 0;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color pageBg = Color(0xFFF5F5E9);

  // ============================================================
  // CONVERSATIONS
  // ============================================================

  final List<Conversation> conversations = mockConversations;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Localized categories
    final categories = [
      l10n.allMessages,
      l10n.restaurants,
      l10n.deliveries,
      l10n.support,
    ];

    return Scaffold(
      backgroundColor: pageBg,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: FarmerAppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const NotificationsScreen(),
                ),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.only(
              right: 16,
            ),
            child: CircleAvatar(
              backgroundImage:
                  AssetImage(
                'assets/profile.png',
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          const SizedBox(height: 12),

          // ======================================================
          // SEARCH BAR
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextField(
              decoration:
                  InputDecoration(
                hintText:
                    l10n.searchConversations,

                hintStyle:
                    TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 14,
                ),

                prefixIcon:
                    const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 0,
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  borderSide:
                      BorderSide(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                  borderSide:
                      const BorderSide(
                    color:
                        primaryGreen,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CATEGORY FILTERS
          // ======================================================

          SizedBox(
            height: 36,

            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              itemCount:
                  categories.length,

              itemBuilder:
                  (context, index) {
                final isSelected =
                    _selectedCategoryIndex ==
                        index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex =
                          index;
                    });
                  },

                  child: Container(
                    margin:
                        const EdgeInsets.only(
                      right: 8,
                    ),

                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    decoration:
                        BoxDecoration(
                      color: isSelected
                          ? primaryGreen
                          : Colors.white,

                      borderRadius:
                          BorderRadius
                              .circular(20),

                      border:
                          Border.all(
                        color: isSelected
                            ? primaryGreen
                            : Colors.grey
                                .shade300,
                      ),
                    ),

                    child: Text(
                      categories[index],

                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : primaryGreen,

                        fontSize: 13,

                        fontWeight:
                            isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ======================================================
          // CONVERSATION LIST
          // ======================================================

          Expanded(
            child:
                ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),

              itemCount:
                  conversations.length,

              itemBuilder:
                  (context, index) {
                final item =
                    conversations[index];

                return ConversationCard(
                  name: item.name,
                  message: item.message,
                  time: item.time,
                  avatarUrl:
                      item.avatarUrl,
                  unreadCount:
                      item.unreadCount,
                  isOnline:
                      item.isOnline,
                );
              },
            ),
          ),
        ],
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
          const FarmerBottomNavBar(
        currentIndex: 3,
      ),
    );
  }
}