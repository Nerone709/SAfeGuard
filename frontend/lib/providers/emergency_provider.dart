import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// Provider di Stato: EmergencyProvider
// Gestisce lo stato e la logica relativi all'attivazione delle emergenze
class EmergencyProvider extends ChangeNotifier {
  bool _isSendingSos = false;

  bool get isSendingSos => _isSendingSos;

  // Riferimento alla collezione "active_emergencies" su database
  final CollectionReference _firestore = FirebaseFirestore.instance.collection('active_emergencies');

  // Invia un segnale SOS immediato
  Future<bool> sendInstantSos({
    required String userId,
    required String? email,
    required String? phone,
    String type = "Generico"
  }) async {

    try {
      // 1. Imposta lo stato su "invio in corso" e notifica la UI
      _isSendingSos = true;
      notifyListeners();

      // 1. Prende la posizione attuale
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 3. Prepara l'oggetto dati da salvare nel database
      final Map<String, dynamic> emergencyData = {
        "id": userId,
        "email": email ?? "N/A",
        "phone": phone ?? "N/A",
        "type": type,
        "lat": position.latitude,
        "lng": position.longitude,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "active",
      };

      // 4. Scrive sul database
      await _firestore.doc(userId).set(emergencyData);

      // Simula un piccolo ritardo per migliorare l'esperienza utente
      await Future.delayed(const Duration(seconds: 1));
      return true;

      // Gestione Errori
    } catch (e) {
      _isSendingSos = false;
      notifyListeners();
      return false;
    }
  }

// Interrompe l'SOS attivo per un determinato utente
  Future<void> stopSos(String userId) async {
    await _firestore.doc(userId).delete();
    _isSendingSos = false;
    notifyListeners();
  }
}