import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../home/application/store_controller.dart';
import '../pages/edit_profile_page.dart';
import '../pages/change_password_page.dart';
import '../pages/order_history_page.dart';
import '../pages/static_content_page.dart';
import '../pages/language_page.dart';
import 'logout_dialog.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          // Profile Header
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/profile_placeholder.png'), // Need a placeholder
                backgroundColor: Color(0xFFF3F8FC),
              ),
              const SizedBox(width: 16),
              const Text(
                'Madiha Aroa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF243041),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          _ProfileMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.assignment_outlined,
            title: 'Order History',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StaticContentPage(
                  title: 'About App',
                  content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                ),
              ),
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StaticContentPage(
                  title: 'Privacy Policy',
                  content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                ),
              ),
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StaticContentPage(
                  title: 'Terms & Conditions',
                  content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                ),
              ),
            ),
          ),
          _ProfileMenuItem(
            icon: Icons.language_outlined,
            title: 'Language',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LanguagePage()),
            ),
          ),
          
          // Push Notifications Toggle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, color: Color(0xFF243041), size: 22),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Push Notifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF243041),
                    ),
                  ),
                ),
                Switch(
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF5A91C4),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFE8EBF0),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          // Log Out
          GestureDetector(
            onTap: () async {
              final confirm = await LogoutDialog.show(context);
              if (confirm == true) {
                ref.read(authControllerProvider.notifier).logout();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.logout_outlined, color: Color(0xFF5A91C4), size: 22),
                  const SizedBox(width: 16),
                  const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5A91C4),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Color(0xFF5A91C4), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF243041), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF243041),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8E98A5), size: 20),
          ],
        ),
      ),
    );
  }
}
