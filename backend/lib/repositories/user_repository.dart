// File: backend/lib/repositories/user_repository.dart

import 'dart:convert';
import 'dart:math' as math; // <--- IMPORTANTE per i calcoli GPS
import 'package:firedart/firedart.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente_generico.dart';

class UserRepository {
  // Riferimenti alle collezioni usate nel database.
  CollectionReference get _usersCollection =>
      Firestore.instance.collection('users');
  CollectionReference get _phoneVerifications =>
      Firestore.instance.collection('phone_verifications');

  //  HELPER GEOGRAFICO
  // Calcola la distanza in km tra due coordinate
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(c)); // 2 * Raggio Terra
  }

  // Cerca un utente nella collezione 'users' tramite il campo 'email'
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final pages = await _usersCollection
        .where('email', isEqualTo: email.toLowerCase())
        .get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // Cerca un utente nella collezione 'users' tramite il campo 'telefono'
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    final pages = await _usersCollection
        .where('telefono', isEqualTo: phone)
        .get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // Cerca un utente nella collezione 'users' tramite il campo 'id'
  Future<Map<String, dynamic>?> findUserById(int id) async {
    final pages = await _usersCollection.where('id', isEqualTo: id).get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // Salva un nuovo utente nel DB
  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    final int newId = DateTime.now().millisecondsSinceEpoch;
    final userData = newUser.toJson();
    userData['id'] = newId;

    final String docId = newId.toString();

    await _usersCollection.document(docId).set(userData);

    if (newUser is Soccorritore || (userData['isSoccorritore'] == true)) {
      return Soccorritore.fromJson(userData);
    } else {
      return Utente.fromJson(userData);
    }
  }

  // Crea utente per flussi esterni
  Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData, {
    String collection = 'users',
  }) async {
    if (userData['id'] == null || userData['id'] == 0) {
      userData['id'] = DateTime.now().millisecondsSinceEpoch;
    }
    final String docId = userData['id'].toString();
    await Firestore.instance
        .collection(collection)
        .document(docId)
        .set(userData);
    return userData;
  }

  // Utility per trovare il DocId
  Future<String?> _findDocIdByIntId(int id) async {
    final docId = id.toString();
    try {
      await _usersCollection.document(docId).get();
      return docId;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserGeneric(int id, Map<String, dynamic> updates) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update(updates);
    } else {
      throw Exception("Utente con ID $id non trovato.");
    }
  }

  Future<void> updateUserField(int id, String fieldName, dynamic value) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update({fieldName: value});
    }
  }

  // NUOVO: Aggiorna la posizione dell'utente
  Future<void> updateUserLocation(int id, double lat, double lng) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update({
        'lastLat': lat,
        'lastLng': lng,
        'lastPositionUpdate': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<bool> deleteUser(int id) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).delete();
      return true;
    }
    return false;
  }

  Future<void> addToArrayField(int id, String fieldName, dynamic item) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;
    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];
    list.add(item);
    await _usersCollection.document(docId).update({fieldName: list});
  }

  Future<void> removeFromArrayField(
    int id,
    String fieldName,
    dynamic item,
  ) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;
    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];
    final itemJson = jsonEncode(item);
    list.removeWhere((element) => jsonEncode(element) == itemJson);
    await _usersCollection.document(docId).update({fieldName: list});
  }

  // --- OTP Logic ---
  Future<void> saveOtp(String telefono, String otp) async {
    await _phoneVerifications.document(telefono).set({
      'otp': otp,
      'telefono': telefono,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> verifyOtp(String telefono, String otp) async {
    final docRef = _phoneVerifications.document(telefono);
    if (!await docRef.exists) return false;
    final data = await docRef.get();
    if (data['otp'] == otp) {
      await docRef.delete();
      return true;
    }
    return false;
  }

  Future<void> markUserAsVerified(String identifier) async {
    final idLower = identifier.toLowerCase();
    var pages = await _usersCollection.where('email', isEqualTo: idLower).get();
    if (pages.isEmpty) {
      pages = await _usersCollection
          .where('telefono', isEqualTo: identifier)
          .get();
    }
    if (pages.isNotEmpty) {
      await _usersCollection.document(pages.first.id).update({
        'isVerified': true,
        'attivo': true,
      });
    }
  }

  // --- LOGICA DI RICERCA TOKEN ---

  // 1. Trova TUTTI i Token dei Soccorritori
  Future<List<String>> findRescuerTokens() async {
    try {
      final rescuers = await _usersCollection
          .where('isSoccorritore', isEqualTo: true)
          .get();

      return rescuers
          .map((doc) => doc.map['tokenFCM'] as String?)
          .whereType<String>()
          .where((token) => token.isNotEmpty)
          .toList();
    } catch (e) {
      print('Errore query token soccorritori: $e');
      return [];
    }
  }

  // 2. Trova Utenti VICINI (Logica REALE basata su GPS)
  Future<List<String>> findNearbyTokensReal(
    double sosLat,
    double sosLng,
    double radiusKm,
  ) async {
    print('🔍 Ricerca geografica: raggio $radiusKm km da ($sosLat, $sosLng)');

    try {
      // Scarica solo i cittadini normali (i soccorritori sono gestiti a parte)
      final users = await _usersCollection
          .where('isSoccorritore', isEqualTo: false)
          .get();

      List<String> validTokens = [];

      for (var doc in users) {
        final data = doc.map;

        // Verifica che l'utente abbia posizione e token
        if (data['lastLat'] != null &&
            data['lastLng'] != null &&
            data['tokenFCM'] != null &&
            (data['tokenFCM'] as String).isNotEmpty) {
          double userLat = (data['lastLat'] as num).toDouble();
          double userLng = (data['lastLng'] as num).toDouble();

          // Calcola distanza reale
          double distance = _calculateDistance(
            sosLat,
            sosLng,
            userLat,
            userLng,
          );

          if (distance <= radiusKm) {
            print(
              '   -> Trovato cittadino a ${distance.toStringAsFixed(2)} km',
            );
            validTokens.add(data['tokenFCM']);
          }
        }
      }
      return validTokens;
    } catch (e) {
      print('Errore query utenti vicini: $e');
      return [];
    }
  }
}
