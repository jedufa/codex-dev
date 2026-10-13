import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
