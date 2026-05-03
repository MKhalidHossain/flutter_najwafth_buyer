import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF243041), size: 28),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          const Text(
            'New',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243041),
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            icon: Icons.cancel_outlined,
            iconColor: Colors.red,
            text: 'Lorem ipsum is a dummy or',
            time: '01 min',
          ),
          _buildNotificationItem(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            text: 'Lorem ipsum is a dummy or',
            time: '01 min',
          ),
          _buildNotificationItem(
            icon: Icons.add_circle_outline,
            iconColor: Colors.lightGreen,
            text: 'Lorem ipsum is a dummy or',
            time: '01 min',
          ),
          _buildNotificationItem(
            icon: Icons.rocket_launch_outlined,
            iconColor: Colors.blue,
            text: 'Lorem ipsum is a dummy or',
            time: '01 min',
          ),
          
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '15 min'),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '15 min'),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '15 min'),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '20 min'),

          const SizedBox(height: 24),
          const Text(
            'Earlier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243041),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '31 min'),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '31 min'),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '31 min'),
          _buildTextNotification('Lorem ipsum is a dummy or placeholder text commonly used in graphic', '58 min'),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF243041),
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E98A5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextNotification(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF243041),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E98A5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE8EBF0), height: 1),
        ],
      ),
    );
  }
}
