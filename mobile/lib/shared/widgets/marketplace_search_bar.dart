import 'package:flutter/material.dart';

class MarketplaceSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool readOnly;
  final String? hintText;
  final Color primaryColor;
  final Color backgroundColor;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final double height;
  final FocusNode? focusNode;

  const MarketplaceSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.readOnly = false,
    this.hintText,
    this.primaryColor = const Color(0xFF0F5A27),
    this.backgroundColor = Colors.white,
    this.showFilterButton = false,
    this.onFilterTap,
    this.activeFilterCount = 0,
    this.showBackButton = false,
    this.onBackTap,
    this.height = 46,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color accentOrange = Color(0xFFF57C00);

    return Row(
      children: [
        // Optional Back Button
        if (showBackButton) ...[
          GestureDetector(
            onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
            child: Container(
              width: height,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: textDark,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Main Search Bar
        Expanded(
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    readOnly: readOnly,
                    onTap: onTap,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    style: const TextStyle(fontSize: 14, color: textDark),
                    decoration: InputDecoration(
                      hintText: hintText ?? 'Search products, farms, or locations...',
                      hintStyle: const TextStyle(fontSize: 13, color: textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (!readOnly && controller != null)
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller!,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return GestureDetector(
                        onTap: () {
                          controller?.clear();
                          onClear?.call();
                          onChanged?.call('');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: Colors.grey.shade400,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),


        // Optional Filter Button with Live Badge
        if (showFilterButton) ...[
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  width: height,
                  height: height,
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0 ? primaryColor : backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: activeFilterCount > 0
                          ? primaryColor
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: activeFilterCount > 0 ? Colors.white : primaryColor,
                    size: 21,
                  ),
                ),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: accentOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
