
// lib/Views/admin/order/add_order_screen/widgets/loading_state_wrapper.dart
import 'package:flutter/material.dart';

class LoadingStateWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  const LoadingStateWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (loadingMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                loadingMessage!,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      );
    }
    return child;
  }
}