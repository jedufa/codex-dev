import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}
