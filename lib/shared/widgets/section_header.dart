import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
      ],
    );
  }
}
