import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/realtime_map.dart';

class SafeCheckScreen extends StatelessWidget {
  // Parametri opzionali per rendere la schermata dinamica in base all'evento
  final String title;
  final String locationName;
  final String instructionText;

  const SafeCheckScreen({
    super.key,
    this.title = "ALLERTA ALLUVIONE",
    this.locationName = "Via Roma",
    this.instructionText = "Dirigiti a Nord verso 'Parco Mercatello' (Punto C1)",
  });

  static const Color backgroundRed = ColorPalette.primaryBrightRed;
  static const Color safeGreen = ColorPalette.safeGreen;

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività (stile confirm_emergency_screen.dart)
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 600;

    final double titleSize = isWideScreen ? 50 : 36;
    final double bodySize = isWideScreen ? 22 : 16;
    final double buttonTextSize = isWideScreen ? 24 : 18;

    return Scaffold(
      backgroundColor: backgroundRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 10),

              // 1. Titolo Allerta
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: titleSize,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 20),

              // 2. Mappa
              Expanded(
                child: _buildMapPlaceholder(isWideScreen),
              ),

              const SizedBox(height: 20),

              // 3. Testi Istruzioni
              Column(
                children: [
                  Text(
                    "Rivelata emergenza nella tua area.\nMantieni la calma.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: bodySize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: bodySize,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: "Area '$locationName' allagata.\n",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: instructionText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 4. Pulsanti Azione
              Column(
                children: [
                  // Pulsante SOS (Rosso con bordo nero)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE60000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        //TODO: Azione pulsante rosso
                      },
                      child: Text(
                        "HO BISOGNO DI AIUTO (SOS)",
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pulsante STO BENE
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: safeGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () => _handleSafeCheck(context),
                      child: Text(
                        "STO BENE",
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget mappa
  Widget _buildMapPlaceholder(bool isWideScreen) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: ColorPalette.backgroundDarkBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // ClipRRect taglia gli angoli della mappa per seguire il bordo arrotondato
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: const RealtimeMap(), // <--- QUI C'È LA MAPPA VERA
      ),
    );
  }

  // Logica per gestire il "Sto Bene"
  Future<void> _handleSafeCheck(BuildContext context) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Errore utente non identificato")),
        );
        return;
      }

      // Feedback visivo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invio status in corso..."),
          duration: Duration(milliseconds: 800),
        ),
      );

      // Esempio di chiamata al provider (da implementare in EmergencyProvider)
      /* await context.read<EmergencyProvider>().sendSafeStatus(
            userId: user.id.toString(),
            location: "lat,long", // Opzionale: prendere posizione GPS attuale
          );
      */

      // Simulazione attesa rete
      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      // Successo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Grazie! Abbiamo registrato che sei al sicuro."),
          backgroundColor: safeGreen,
        ),
      );

      // Torna alla pagina precedente
      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore di connessione: $e"),
          backgroundColor: backgroundRed,
        ),
      );
    }
  }
}