import 'package:flutter/material.dart';
import 'package:data_models/setting_item.dart'; // Import Model

class GestioneNotificheCittadino extends StatefulWidget {
  const GestioneNotificheCittadino({super.key});

  @override
  State<GestioneNotificheCittadino> createState() => _GestioneNotificheState();
}

class _GestioneNotificheState extends State<GestioneNotificheCittadino> {
  // Lista notifiche basata sul Model
  final List<SettingItem> permissions = [
    SettingItem(title: 'Notifiche SMS', isEnabled: false),
    SettingItem(title: 'Notifiche e-mail', isEnabled: false),
    SettingItem(title: 'Silenzia notifiche', isEnabled: false),
    SettingItem(title: 'Notifiche push', isEnabled: false),
    SettingItem(title: 'Aggiornamenti', isEnabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFF12345A);
    const Color bgColor = Color(0xFF0E2A48);
    const Color activeColor = Color(0xFFEF923D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.notifications,
                    color: Colors.yellowAccent,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Gestione\nNotifiche",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),

            // LISTA
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.separated(
                    itemCount: permissions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      return _buildSwitchItem(permissions[index], activeColor);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 320),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(SettingItem item, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          // Expanded serve se il testo è lungo
          child: Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Switch(
          value: item.isEnabled,
          onChanged: (val) {
            setState(() {
              item.isEnabled = val;
            });
          },
          activeThumbColor: activeColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ],
    );
  }
}
