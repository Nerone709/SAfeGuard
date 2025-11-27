import 'package:flutter/material.dart';

// LA CLASSE DEVE CHIAMARSI COSÌ:
class GestioneModificaProfiloCittadino extends StatefulWidget {
  const GestioneModificaProfiloCittadino({super.key});

  @override
  State<GestioneModificaProfiloCittadino> createState() =>
      _GestioneModificaProfiloCittadinoState();
}

class _GestioneModificaProfiloCittadinoState
    extends State<GestioneModificaProfiloCittadino> {
  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _indirizzoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: "Mario");
    _cognomeController = TextEditingController(text: "Rossi");
    _emailController = TextEditingController(text: "mario.rossi@email.com");
    _telefonoController = TextEditingController(text: "+39 333 1234567");
    _indirizzoController = TextEditingController(text: "Via Roma 1, Milano");
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _indirizzoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color accentColor = Color(0xFFEF923D);
    const Color iconColor = Color(0xFFE3C63D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
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
                      Icons.person_outline,
                      color: iconColor,
                      size: 40,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Modifica\nProfilo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildField("Nome", _nomeController),
                    _buildField("Cognome", _cognomeController),
                    _buildField("Email", _emailController, isEmail: true),
                    _buildField("Telefono", _telefonoController, isPhone: true),
                    _buildField("Indirizzo", _indirizzoController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profilo aggiornato!"),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "SALVA MODIFICHE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : (isPhone ? TextInputType.phone : TextInputType.text),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black12,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
