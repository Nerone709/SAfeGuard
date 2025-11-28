import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';

// --- IMPORT DELLE SCHERMATE FUNZIONALI ---
import 'package:frontend/ui/screens/medical/condizioni_mediche_screen.dart';
import 'package:frontend/ui/screens/medical/allergie_screen.dart';
import 'package:frontend/ui/screens/medical/medicinali_screen.dart';
import 'package:frontend/ui/screens/medical/contatti_emergenza_screen.dart';

class GestioneCartellaClinicaCittadino extends StatelessWidget {
  const GestioneCartellaClinicaCittadino({super.key});

  @override
  Widget build(BuildContext context) {
    // Leggi lo stato del soccorritore per i colori dinamici
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Colori dinamici
    final Color cardColor = isRescuer ? const Color(0xFFD65D01) : const Color(0xFF12345A);
    final Color bgColor = isRescuer ? const Color(0xFFEF932D) : const Color(0xFF0E2A48);

    return Scaffold(
      backgroundColor: bgColor,


      // === 1. APPBAR CORRETTA E UNIFORME CON PADDING ===
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        // Rimuoviamo il leading per inserire l'icona nel titolo e applicare padding uniforme
        automaticallyImplyLeading: false,

        // Nuovo Title Widget per includere Icona, Testo e Tasto Back
        title: Padding(
          padding: const EdgeInsets.only(left: 0, right: 16.0, top: 20.0), // Padding laterale e verticale superiore
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tasto Indietro (funge da Leading)
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(width: 10), // Spazio tra freccia e icona

              // 2. Icona e Titolo (Aumentati)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.assignment_ind_outlined,
                    color: Colors.white,
                    size: 40, // Dimensione uniforme
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Cartella\nClinica", // Corretto da "Cartella\n Clinica" a una riga
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35, // Dimensione uniforme (più piccola per stare in riga)
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Disabilitiamo il centro del titolo per far funzionare il Row completo
        centerTitle: false,
        toolbarHeight: 80.0, // Aumenta l'altezza della barra per il padding verticale di 20.0
      ),
      // ===================================

      // === 2. BODY CORRETTO (Contenuto della Card) ===
      body: SafeArea(
        child: Column(
          children: [
            // Questo Padding simula il 'vertical: 20.0' mancante all'inizio del body
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Expanded(
                child: Container(
                  width: double.infinity,
                  // Aggiungiamo un Padding orizzontale di 16.0 mancante in tutto il corpo
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: cardColor, // Colore sfondo dinamico (scuro)
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30.0,
                      horizontal: 20.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. Condizioni Mediche
                          _buildMenuButton(
                            context,
                            label: "Condizioni Mediche",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const CondizioniMedicheScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 2. Allergie
                          _buildMenuButton(
                            context,
                            label: "Allergie",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllergieScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 3. Medicinali
                          _buildMenuButton(
                            context,
                            label: "Medicinali",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MedicinaliScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // 4. Contatti di emergenza
                          _buildMenuButton(
                            context,
                            label: "Contatti di emergenza",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const ContattiEmergenzaScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PULSANTE MENU (Invariato) ---
  Widget _buildMenuButton(
      BuildContext context, {
        required String label,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}