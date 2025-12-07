import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../style/color_palette.dart';
import 'mini_map_preview.dart';
// Costruzione della pagina del dettaglio dell'emergenza
class EmergencyDetailDialog extends StatefulWidget {
  final Map<String, dynamic> item;

  const EmergencyDetailDialog({super.key, required this.item});

  @override
  State<EmergencyDetailDialog> createState() => _EmergencyDetailDialogState();
}

class _EmergencyDetailDialogState extends State<EmergencyDetailDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Costruzione dell'icona
  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'INCENDIO':
        return Icons.local_fire_department;
      case 'TSUNAMI':
        return Icons.water;
      case 'ALLUVIONE':
        return Icons.flood;
      case 'MALESSERE':
        return Icons.medical_services;
      case 'BOMBA':
        return Icons.warning;
      default:
        return Icons.warning_amber_rounded;
    }
  }

  // Pagina 0: costruzione del widget che contiene i dettagli sull'emergenza e i dettagli del cittadino
  @override
  Widget build(BuildContext context) {
    final double? eLat = (widget.item['lat'] as num?)?.toDouble();
    final double? eLng = (widget.item['lng'] as num?)?.toDouble();
    final IconData icon = _getIconForType(widget.item['type'].toString());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 10,
      backgroundColor: ColorPalette.cardDarkOrange,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 550),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Pagina 1: dettaglio emergenza
                    _buildEmergencyPage(eLat, eLng, icon),
                    // Pagina 2: dettaglio cittadino
                    _buildCitizenPage(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  bool isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.white : Colors.white38,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(
                _currentPage == 0
                    ? "Scorri per info cittadino >"
                    : "< Torna ai dettagli",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pagina 1: dettaglio emergenza
  Widget _buildEmergencyPage(double? lat, double? lng, IconData icon) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    widget.item['type'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.item['description']?.toString() ?? 'Nessuna descrizione',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (lat != null && lng != null)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: MiniMapPreview(lat: lat, lng: lng),
                ),
              )
            else
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Posizione non disponibile",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Pagina 2: dettaglio cittadino
  Widget _buildCitizenPage() {
    return FutureBuilder<DocumentSnapshot>(
      // Query diretta alla collezione users
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.item['user_id'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Errore caricamento dati",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Cittadino non trovato
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 50, color: Colors.white54),
                SizedBox(height: 10),
                Text(
                  "Profilo cittadino non trovato\noppure\nsegnalazione effettuata da un\nsoccorritore",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Dettagli Cittadino",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        "Nome:",
                        "${userData['nome'] ?? userData['name'] ?? 'N/D'}",
                      ),
                      _buildInfoRow(
                        "Cognome:",
                        "${userData['cognome'] ?? userData['surname'] ?? ''}",
                      ),
                      _buildInfoRow(
                        "Telefono:",
                        "${userData['telefono'] ?? userData['phone'] ?? 'N/D'}",
                      ),
                      _buildInfoRow(
                        "Età:",
                        _calculateAge(userData['dataDiNascita']),
                      ),

                      const Divider(color: Colors.white24, height: 20),

                      const Text(
                        "Note Mediche / Allergie:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userData['allergie']?.toString().isNotEmpty == true
                            ? userData['allergie'].toString()
                            : "Nessuna patologia segnalata",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Costruzione delle righe di testo
Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
  );
}

// Calcola l'età in base alla data di nascita dell'utente
String _calculateAge(dynamic birthDateData) {
  if (birthDateData == null) return "Non condivisa";

  DateTime date = DateTime.now();

  if (birthDateData is Timestamp) {
    date = birthDateData.toDate();
  } else if (birthDateData is String) {
    final parsed = DateTime.tryParse(birthDateData);
    if (parsed == null) {
      return "Non condivisa";
    }
    date = parsed;
  }

  final DateTime today = DateTime.now();

  int age = today.year - date.year;

  if (today.month < date.month ||
      (today.month == date.month && today.day < date.day)) {
    age--;
  }

  return "$age anni";
}
