import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search books, authors, stores...',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFA6AFBA)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFDDE2E9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFDDE2E9)),
          ),
          suffixIcon: Container(
            width: 34,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(color: const Color(0xFF5A91C4), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.search, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
