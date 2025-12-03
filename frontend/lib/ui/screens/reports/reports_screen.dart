import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/widgets/emergency_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/services/user_api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Schermata Report Specifico
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Stato caricamento
  bool _isLoading = false;
  bool _needsHelp = false;

  final TextEditingController _descriptionController = TextEditingController();

  EmergencyItem? _selectedEmergency;

  //LOGICA DI INVIO IBRIDA (INTERNET + SMS)
  Future<void> _sendEmergency() async {
    // 1. Validazione Campi
    final String description = _descriptionController.text;

    if (_selectedEmergency == null) {
      _showSnackBar(
        content: 'Seleziona un tipo di emergenza',
        color: ColorPalette.emergencyButtonRed,
      );
      return;
    }

    // 2. Avvio Caricamento
    setState(() => _isLoading = true);

    try {
      // 3. Ottenimento Posizione GPS
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final String type = _selectedEmergency!.label;

      // 4. Controllo Connessione Internet
      final connectivityResult = await Connectivity().checkConnectivity();
      bool hasInternet = !connectivityResult.contains(ConnectivityResult.none);

      if (hasInternet) {
        // --- CASO A: C'È INTERNET (Usa Backend) ---
        print("🌐 Internet OK. Invio al server...");

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.authToken;

        if (token == null) {
          _showSnackBar(
            content: 'Errore: Utente non loggato',
            color: Colors.red,
          );
          return;
        }

        final api = UserApiService();
        await api.callSOSApi(
          latitude: position.latitude,
          longitude: position.longitude,
          authToken: token,
          type: type,
          description: description,
        );

        if (mounted) {
          _showSnackBar(
            content: '✅ Segnalazione inviata al server!',
            color: Colors.green,
          );
          Navigator.pop(context); // Torna alla Home
        }
      } else {
        // --- CASO B: NO INTERNET (Usa SMS) ---
        print("📵 No Internet. Preparazione SMS...");

        await _sendSmsFallback(
          lat: position.latitude,
          lng: position.longitude,
          type: type,
          description: description,
        );

        //l'utente deve inviare l'SMS manualmente
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Errore invio: $e");
      if (mounted) {
        _showSnackBar(
          content: 'Errore durante l\'invio: $e',
          color: ColorPalette.emergencyButtonRed,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper per inviare SMS
  Future<void> _sendSmsFallback({
    required double lat,
    required double lng,
    required String type,
    required String description,
  }) async {
    // NUMERO CENTRALE OPERATIVA
    const String emergencyNumber =
        "123"; //Lo invia alla centrale di emergenza(ES. 112, 115)

    final String message =
        "SOS $type\nPosizione: $lat, $lng\nNote: $description\n(Inviato da App SAfeGuard)";

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: <String, String>{'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw Exception("Impossibile aprire l'app messaggi");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;

    Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundMidBlue;
    Color cardColor = isRescuer
        ? ColorPalette.cardDarkOrange
        : ColorPalette.backgroundDarkBlue;
    Color accentColor = isRescuer
        ? ColorPalette.backgroundMidBlue
        : ColorPalette.primaryOrange;

    final double titleSize = isWideScreen ? 50 : 28;
    final double labelFontSize = isWideScreen ? 24 : 14;
    final double inputFontSize = isWideScreen ? 26 : 16;
    final double buttonFontSize = isWideScreen ? 28 : 18;

    return Scaffold(
      backgroundColor: cardColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    "Crea segnalazione",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // Tipi di segnalazione
                SizedBox(
                  height: 60,
                  child: _buildSpecificEmergency(context, isWideScreen),
                ),

                isRescuer
                    ? const SizedBox(height: 40.0)
                    : const SizedBox(height: 20.0),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Aggiungi dettagli alla tua segnalazione",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          18, // Corretto buttonFontSize non disponibile qui
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // TextArea per la descrizione
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  style: TextStyle(fontSize: inputFontSize),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Descrizione...',
                    hintStyle: TextStyle(
                      fontSize: inputFontSize,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                ),

                const SizedBox(height: 20.0),

                // checkbox per la richiesta di aiuto
                if (!isRescuer)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ho bisogno di aiuto",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Checkbox(
                            value: _needsHelp,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _needsHelp = newValue ?? false;
                              });
                            },
                            shape: const CircleBorder(),
                            checkColor: Colors.white,
                            activeColor: accentColor,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return accentColor;
                              }
                              return Colors.white;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20.0),

                // PULSANTE INVIA
                SizedBox(
                  width: double.infinity,
                  height: isWideScreen ? 70 : 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.emergencyButtonRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    // Disabilita il click se sta caricando
                    onPressed: _isLoading ? null : _sendEmergency,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "INVIA EMERGENZA",
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
      ),
    );
  }

  // dropdown menu per la selezione dell'emergenza
  Widget _buildSpecificEmergency(BuildContext context, bool isWideScreen) {
    return SizedBox(
      width: isWideScreen ? 500 : double.infinity,
      child: EmergencyDropdownMenu(
        value: _selectedEmergency,
        hintText: "Segnala il tipo di emergenza",
        items: [
          EmergencyItem(label: "Terremoto", icon: Icons.waves),
          EmergencyItem(label: "Incendio", icon: Icons.local_fire_department),
          EmergencyItem(label: "Tsunami", icon: Icons.water),
          EmergencyItem(label: "Alluvione", icon: Icons.flood),
          EmergencyItem(label: "Malessere", icon: Icons.medical_services),
          EmergencyItem(label: "Bomba", icon: Icons.warning),
        ],
        onSelected: (item) {
          setState(() {
            _selectedEmergency = item;
          });
        },
      ),
    );
  }

  void _showSnackBar({required String content, required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
