import 'package:flutter/material.dart';
import 'package:data_models/setting_item.dart'; // Import Model

class GestionePermessiCittadino extends StatefulWidget {
  const GestionePermessiCittadino({super.key});

  @override
  State<GestionePermessiCittadino> createState() => _GestionePermessiCittadinoState();
}

class _GestionePermessiCittadinoState extends State<GestionePermessiCittadino> {
  // Lista permessi basata sul Model
  final List<SettingItem> permissions = [
    SettingItem(title: 'Accesso alla posizione', isEnabled: true),
    SettingItem(title: 'Accesso ai contatti', isEnabled: false),
    SettingItem(title: 'Notifiche di sistema', isEnabled: true),
    SettingItem(title: 'Accesso alla memoria', isEnabled: false),
    SettingItem(title: 'Accesso al Bluetooth', isEnabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color activeColor = Color(0xFFEF923D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.verified_user, color: Colors.blueAccent, size: 40),
                  const SizedBox(width: 10),
                  const Text(
                    "Gestione\nPermessi",
                    style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.0),
                  ),
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25.0)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.separated(
                    itemCount: permissions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      return _buildSwitchItem(permissions[index], activeColor);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(SettingItem item, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded( // Expanded serve se il testo è lungo
          child: Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Switch(
          value: item.isEnabled,
          onChanged: (val) {
            setState(() {
              item.isEnabled = val;
            });
          },
          activeColor: activeColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ],
    );
  }
}