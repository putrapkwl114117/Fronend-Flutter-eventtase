// event_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(File(imagePath), height: 150, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.solidEdit, size: 18),
                  onPressed: () {
                    // Aksi untuk edit event
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trashAlt, size: 18),
                  onPressed: () {
                    // Aksi untuk delete event
                  },
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.clipboardList, size: 18),
                  onPressed: () {
                    // Aksi untuk buat form pendaftaran event
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
