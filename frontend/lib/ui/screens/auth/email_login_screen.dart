import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/home/home_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata di Login tramite Email e Password.
class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  // Controller per i campi di testo
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isPasswordVisible = false;
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;
    // Usa la dimensione minore (altezza o larghezza) come riferimento per le scale
    final double referenceSize = screenHeight < screenWidth ? screenHeight : screenWidth;

    final double titleFontSize = referenceSize * 0.075;
    final double contentFontSize = referenceSize * 0.045;
    final double verticalPadding = screenHeight * 0.04;
    final double smallSpacing = screenHeight * 0.015;
    final double _ = screenHeight * 0.04;

    // Accesso all'AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final Color buttonColor = ColorPalette.primaryDarkButtonBlue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      //Header
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Stack(
        children: [
          // Sfondo con gradiente e bolle decorative
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ColorPalette.backgroundDeepBlue,
              image: DecorationImage(
                image: AssetImage('assets/backgroundBubbles3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenuto Principale
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView( // Permette lo scroll se la tastiera copre i campi
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: verticalPadding),

                    Text(
                      "Accedi",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.10),

                    // Campo Email
                    _buildTextField(
                        "Email",
                        _emailController,
                        isPassword: false,
                        contentVerticalPadding: 16,
                        fontSize: contentFontSize
                    ),
                    SizedBox(height: smallSpacing),

                    // Campo Password
                    _buildTextField(
                        "Password",
                        _passController,
                        isPassword: true,
                        contentVerticalPadding: 16,
                        fontSize: contentFontSize
                    ),

                    // Messaggio di Errore
                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    SizedBox(height: screenHeight * 0.15),

                    // Bottone Accedi
                    SizedBox(
                      height: referenceSize * 0.12,
                      child: ElevatedButton(
                        // Disabilita il bottone se il provider è in caricamento
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          // Validazione base dei campi
                          if (_emailController.text.isEmpty || _passController.text.isEmpty) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text("Inserisci email e password")),
                            );
                            return;
                          }

                          // 1. Chiamata al metodo login dell'AuthProvider
                          bool success = await authProvider.login(
                            _emailController.text,
                            _passController.text,
                          );
                          // 2. Se il login ha successo, naviga alla Home e rimuove tutte le schermate precedenti
                          if (success) {
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                                  (route) => false,
                            );
                          }
                          // Se fallisce, l'AuthProvider aggiorna errorMessage
                          // e il widget lo mostra automaticamente
                        },

                        // Stile del Bottone
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(color: Colors.white12, width: 1),
                        ),

                        // Contenuto del bottone
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "ACCEDI",
                          style: TextStyle(
                            fontSize: referenceSize * 0.07,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: verticalPadding),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper per costruire i campi di testo
  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        required bool isPassword,
        double contentVerticalPadding = 20,
        required double fontSize
      }) {
    // Determina se il testo deve essere oscurato
    bool obscureText = isPassword ? !_isPasswordVisible : false;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black, fontSize: fontSize),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey, fontSize: fontSize),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 25,
          vertical: contentVerticalPadding,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        // Icona per la visibilità della password
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
            size: fontSize * 1.5,
          ),
          onPressed: _togglePasswordVisibility,
        )
            : null,
      ),
    );
  }
}