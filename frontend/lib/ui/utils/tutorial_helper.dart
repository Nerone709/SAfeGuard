import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:frontend/ui/style/color_palette.dart'; // Assumo tu abbia i colori qui

class TutorialHelper {
  // Metodo statico per avviare il tutorial
  static void showTutorial({
    required BuildContext context,
    required GlobalKey keyMap,
    required GlobalKey keyContacts,
    required GlobalKey keySos,
    required GlobalKey keyNavbar, // Se vuoi evidenziare la navbar
    required VoidCallback onFinish,
  }) {
    // Per la responsività
    final screenSize = MediaQuery.of(context).size;
    TutorialCoachMark(
      targets: _createTargets(
        screenSize: screenSize,
        keyMap: keyMap,
        keyContacts: keyContacts,
        keySos: keySos,
        keyNavbar: keyNavbar,
      ),
      colorShadow: Colors.black, // Colore sfondo scuro
      textSkip: "SALTA",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: onFinish,
      onSkip: () {
        onFinish(); // Segna come completato anche se salta
        return true;
      },
    ).show(context: context);
  }

  static List<TargetFocus> _createTargets({
    required Size screenSize,
    required GlobalKey keyMap,
    required GlobalKey keyContacts,
    required GlobalKey keySos,
    required GlobalKey keyNavbar,
  })
  //Target differenziati per il soccorritore?
  {
    List<TargetFocus> targets = [];

    // Tappa 1: Benvenuto
    targets.add(
      TargetFocus(
        identify: "intro",
        targetPosition: TargetPosition(
          const Size(0, 0),
          const Offset(0, 0),
        ),
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // Il contenuto parte dall'alto e scende
            builder: (context, controller) {
              return Container(
                height: screenSize.height - 100, // -100 per sicurezza su status bar/nav bar
                width: screenSize.width,
                alignment: Alignment.center, // <--- QUI avviene la magia del centraggio
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario al centro
                  children: [
                    SizedBox(
                      height: 200,
                      child: Image.asset("assets/cavalluccio.png"),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20), // Margine laterale
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                      ),
                      child: const Text(
                        "Ciao, sono Neptie!\nSarò il tuo assistente nell'uso di SafeGuard.\n\nRicorda: conoscere bene l'app è fondamentale.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    // Tappa 2: Mappa
    targets.add(
      _buildTarget(
        identify: "map",
        keyTarget: keyMap,
        text: "La mappa mostra le zone con emergenze attive. Ogni informazione è aggiornata in tempo reale.",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,// Forma rettangolare
        radius: 20.0,
      ),
    );

    // Tappa 3: Contatti Emergenza
    targets.add(
      _buildTarget(
        identify: "contacts",
        keyTarget: keyContacts,
        text: "Qui puoi vedere gli ultimi eventi e i tuoi contatti di emergenza.",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top, // Testo sopra perché il bottone è in basso
        shape: ShapeLightFocus.RRect,// Forma rettangolare
        radius: 20.0,
      ),
    );

    // Tappa 4: SOS
    targets.add(
      _buildTarget(
        identify: "sos",
        keyTarget: keySos,
        text: "Il pulsante SOS è essenziale: se sei in pericolo, premilo subito. Invierà un allarme silenzioso.",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top,
        shape: ShapeLightFocus.Circle, // Importante: Cerchio per il bottone SOS
      ),
    );

// Tappa 5: Navbar
    targets.add(
      _buildTarget(
        identify: "navbar",
        keyTarget: keyNavbar, // Questa chiave arriva dai parametri del metodo
        text: "Usa la barra di navigazione per spostarti tra Home, Segnalazione specifica, \nMappa, Emergenze attive e Impostazioni profilo.",
        imagePath: "assets/cavalluccio.png",
        alignText: ContentAlign.top, // Testo sopra la navbar
        shape: ShapeLightFocus.RRect,
        radius: 30.0, // Bordo molto arrotondato per la navbar
      ),
    );

    // Tappa 6: Saluti finali
    targets.add(
      TargetFocus(
        identify: "saluti",
        targetPosition: TargetPosition(
          const Size(0, 0),
          const Offset(0, 0),
        ),
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // Il contenuto parte dall'alto e scende
            builder: (context, controller) {
              return Container(
                height: screenSize.height - 100, // -100 per sicurezza su status bar/nav bar
                width: screenSize.width,
                alignment: Alignment.center, // <--- QUI avviene la magia del centraggio
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario al centro
                  children: [
                    SizedBox(
                      height: 200,
                      child: Image.asset("assets/cavalluccio.png"),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 20), // Margine laterale
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                      ),
                      child: const Text(
                        "Questo è tutto!\nArrivederci e ricorda:\n per qualunque emergenza, io sono qui!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );

    return targets;
  }

  // Helper per costruire il singolo step grafico
  static TargetFocus _buildTarget({
    required String identify,
    required GlobalKey keyTarget,
    required String text,
    required String imagePath,
    ContentAlign alignText = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.RRect,
    double ?radius,
  }) {
    return TargetFocus(
      identify: identify,
      keyTarget: keyTarget,
      shape: shape,
      radius: radius,
      contents: [
        TargetContent(
          align: alignText,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end, // Allinea mascotte a destra
              children: [
                // Nuvoletta Testo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorPalette.backgroundDeepBlue, // Blu scuro come negli screenshot
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Triangolino della nuvoletta (Opzionale, per estetica avanzata)
                CustomPaint(
                  painter: TrianglePainter(strokeColor: ColorPalette.backgroundDeepBlue, paintingStyle: PaintingStyle.fill),
                  child: const SizedBox(height: 10, width: 20),
                ),

                // Mascotte
                SizedBox(
                  height: 150, // Dimensione mascotte
                  child: Image.asset(imagePath), // Assicurati che l'immagine esista
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// Piccolo painter per fare la punta della nuvoletta (Opzionale)
class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;

  TrianglePainter({this.strokeColor = Colors.black, this.strokeWidth = 3, this.paintingStyle = PaintingStyle.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(x, 0)
      ..lineTo(x / 2, y)
      ..lineTo(0, 0);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => true;
}