import 'package:flutter/material.dart';

class PaginationLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final String? noMoreItemsText;
  final Color primaryColor;
  final int? itemCount;
  final VoidCallback? onRetry;

  const PaginationLoadingIndicator({
    super.key,
    bool? isLoading,
    bool? isLoadingMore,
    this.hasMore = true,
    this.noMoreItemsText,
    this.primaryColor = const Color(0xFF0F5A27),
    this.itemCount,
    this.onRetry,
  }) : isLoading = isLoadingMore ?? isLoading ?? false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Loading more produce...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasMore && (itemCount != null && itemCount! > 0)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            noMoreItemsText ?? "You've reached the end of the produce list",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
