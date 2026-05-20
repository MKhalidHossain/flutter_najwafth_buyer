import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 50,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
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
