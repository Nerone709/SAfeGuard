import 'package:flutter/material.dart';

class GestioneNotificheCittadino extends StatelessWidget {
  const GestioneNotificheCittadino({super.key});

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color accentColor = Color(0xFFEF923D); // Arancione

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
                  const Icon(Icons.notifications, color: Color(0xFFE3C63D), size: 40),
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

            // CARD IMPOSTAZIONI
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: const [
                      _NotificationSwitch(title: 'Notifiche push', initialValue: true, activeColor: accentColor),
                      _NotificationSwitch(title: 'Notifiche SMS', initialValue: false, activeColor: accentColor),
                      _NotificationSwitch(title: 'Notifiche e-mail', initialValue: true, activeColor: accentColor),
                      _NotificationSwitch(title: 'Aggiornamenti', initialValue: false, activeColor: accentColor),
                      _NotificationSwitch(title: 'Silenzia notifiche', initialValue: false, activeColor: accentColor),
                    ],
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
}

// Widget interno per lo switch
class _NotificationSwitch extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Color activeColor;

  const _NotificationSwitch({required this.title, required this.initialValue, required this.activeColor});

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (val) => setState(() => _isEnabled = val),
            activeColor: widget.activeColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}