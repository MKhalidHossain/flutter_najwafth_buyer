import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.actionText, this.onActionTap});

  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 26, color : Colors.black, fontWeight: FontWeight.w500))),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(actionText!, style: const TextStyle(fontSize: 14, color: Color(0xFF4F8FC5))),
          ),
      ],
    );
  }
}
