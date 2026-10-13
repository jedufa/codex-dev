import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

class ConnectRequiredState extends StatelessWidget {
  const ConnectRequiredState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: EmptyState(title: title, message: message),
      ),
    );
  }
}
