import 'package:flutter/material.dart';
import '../../domain/store_models.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.onSignOutTap, required this.selectedLanguage});

  final VoidCallback onSignOutTap;
  final AppLanguage? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language: ${selectedLanguage?.label ?? 'English'}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onSignOutTap, child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}
