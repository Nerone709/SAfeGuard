import 'package:flutter/material.dart';
// IMPORT MODEL
import 'package:data_models/help_request_item.dart';

// IMPORT SCHERMATE COLLEGATE
import 'package:frontend/ui/screens/profile/gestione_notifiche_cittadino.dart';
import 'package:frontend/ui/screens/profile/gestione_permessi_cittadino.dart';
import 'package:frontend/ui/screens/profile/gestione_modifica_profilo_cittadino.dart';
import 'package:frontend/ui/screens/medical/gestione_cartella_clinica_cittadino.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final bool isSoccorritore;
  const ProfileSettingsScreen({super.key, required this.isSoccorritore});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Dati simulati delle richieste (In futuro verranno dal Backend/Provider)
  final List<HelpRequestItem> requests = [
    HelpRequestItem(title: "Richiesta ambulanza", time: "02:00 AM", status: "Incompleta", isComplete: false, type: "ambulance"),
    HelpRequestItem(title: "Terremoto", time: "12:30 AM", status: "Completata", isComplete: true, type: "earthquake"),
    HelpRequestItem(title: "Incendio", time: "3:50 PM", status: "Completata", isComplete: true, type: "fire"),
  ];

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    const Color kBackgroundColor = Color(0xFF12345A);
    const Color kCardColor = Color(0xFF0E2A48);
    const Color kAccentOrange = Color(0xFFEF923D);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER PROFILO
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: kAccentOrange,
                          child: const CircleAvatar(
                            radius: 42,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=11'),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: kBackgroundColor, width: 2)),
                            child: const Icon(Icons.edit, size: 16, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 20),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ciao,", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("Mario Rossi", style: TextStyle(color: kAccentOrange, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // CAROSELLO
                const Text("Impostazioni", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSettingCard("Notifiche", "Gestione Notifiche", Icons.notifications_active, Colors.yellow, kCardColor, () => _navigateTo(context, const GestioneNotificheCittadino())),
                      const SizedBox(width: 15),
                      _buildSettingCard("Cartella clinica", "Impostazioni", Icons.medical_services_outlined, Colors.white, kCardColor, () => _navigateTo(context, const GestioneCartellaClinicaCittadino())),
                      const SizedBox(width: 15),
                      _buildSettingCard("Permessi", "Gestione Permessi", Icons.security, Colors.blueAccent, kCardColor, () => _navigateTo(context, const GestionePermessiCittadino())),
                      const SizedBox(width: 15),
                      _buildSettingCard("Modifica Profilo", "Modifica Profilo", Icons.settings, Colors.grey, kCardColor, () => _navigateTo(context, const GestioneModificaProfiloCittadino())),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // LISTA RICHIESTE (Generata dai Model)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Richieste di aiuto", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(onPressed: () {}, child: const Text("Guarda Tutto", style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline)))
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Generazione dinamica della lista
                      ...requests.map((req) => _buildRequestItem(req)),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Card
  Widget _buildSettingCard(String title, String subtitle, IconData icon, Color iconColor, Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140, height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Helper Request Item basato sul Modello
  Widget _buildRequestItem(HelpRequestItem item) {
    // Mappatura icone/colori in base al tipo (logica UI)
    IconData icon;
    Color color;
    switch (item.type) {
      case 'fire':
        icon = Icons.local_fire_department;
        color = Colors.deepOrange;
        break;
      case 'earthquake':
        icon = Icons.broken_image;
        color = Colors.brown;
        break;
      default:
        icon = Icons.local_fire_department_outlined;
        color = Colors.orangeAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(item.time, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
              ],
            ),
          ),
          Text(
            item.status,
            style: TextStyle(color: item.isComplete ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}