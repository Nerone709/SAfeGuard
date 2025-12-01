import 'package:frontend/ui/style/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DeleteProfilePage extends StatelessWidget {

  const DeleteProfilePage({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    //Variabili per responsiveness
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;
    final double titleSize = isWideScreen ? 50 : 28;
    final double buttonFontSize = isWideScreen ? 32 : 22;

    //Variabile per tema colori
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    return Scaffold(
      backgroundColor: isRescuer? ColorPalette.primaryOrange: ColorPalette.backgroundMidBlue,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Tasto indietro
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),

              const SizedBox(height: 20),

              // Box di testo
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isRescuer? ColorPalette.cardDarkOrange: ColorPalette.primaryDarkButtonBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      "Elimina profilo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Secondo box di testo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                    color: isRescuer? ColorPalette.cardDarkOrange: ColorPalette.primaryDarkButtonBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Sei assolutamente sicuro?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Questa azione è irreversibile.\n"
                          "Eliminerà permanentemente il tuo account\n"
                          "e tutti i dati associati,\n"
                          "incluse le tue informazioni sanitarie.\n\n"
                          "Eliminare l’account non ti esenterà\n"
                          "da eventuali pene legate a segnalazioni false.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bottone elimina profilo
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:()=>{

                    //Logica di eliminazione account
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Account eliminato",
                      ),
                    ),
                    ),
                    Navigator.pop(context)
                  },

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: ColorPalette.emergencyButtonRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Elimina Profilo",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
