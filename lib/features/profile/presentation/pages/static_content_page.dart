import 'package:flutter/material.dart';

class StaticContentPage extends StatelessWidget {
  const StaticContentPage({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

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
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF243041),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF243041),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF243041),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
