import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class EmergencyCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap; // Opzionale: per gestire il click in futuro

  const EmergencyCard({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final bgColor = !isRescuer ? ColorPalette.backgroundDeepBlue : ColorPalette.amberOrange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icona Grande
            Icon(Icons.emergency, size: 60, color: Colors.white),

            const SizedBox(height: 16),

            // Titolo (Maiuscolo e Grassetto)
            Text(
              title.toUpperCase(), // Forza il maiuscolo qui per sicurezza
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}