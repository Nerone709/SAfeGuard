import 'dart:convert'; // Necessario per confrontare oggetti complessi nella rimozione
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:collection/collection.dart';

// SIMULAZIONE DATABASE (Mappa in memoria)
final Map<String, Map<String, dynamic>> _simulatedDatabase = {
  // Utente Standard di esempio
  'mario.rossi@gmail.com': {
    'id': 101,
    'email': 'mario.rossi@gmail.com',
    'telefono': '+393331234567',
    'passwordHash': 'password123',
    'nome': 'Mario',
    'cognome': 'Rossi',
    'isVerified': false,
    'otp': 'xxxx',
    // Campi inizializzati per testare il profile service
    'permessi': {},
    'condizioni': {},
    'allergie': ['Polline'],
    'medicinali': [],
    'contattiEmergenza': []
  },
  // Altri utenti di test...
  'solo.telefono@gmail.com': {
    'id': 103,
    'email': 'solo.telefono@gmail.com',
    'telefono': '+393457654321',
    'passwordHash': 'telefono_pass',
    'nome': 'Anna',
    'cognome': 'B.',
    'isVerified': false,
    'otp': 'xxxx',
  },
  'luca.verdi@soccorritore.gmail': {
    'id': 202,
    'email': 'luca.verdi@soccorritore.gmail',
    'passwordHash': 'password456',
    'nome': 'Luca',
    'cognome': 'Verdi',
    'isVerified': false,
    'otp': 'xxxx',
  },
};

class UserRepository {
  static final Map<String, String> _otpCache = {};

  // --- METODI ESISTENTI (LOGIN) ---
  // ... (Questi metodi erano già presenti nel file originale)

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    return _simulatedDatabase[email];
  }

  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    return _simulatedDatabase.values.firstWhereOrNull(
          (user) => user['telefono'] == phone,
    );
  }

  Future<bool> isVerified({int? id, String? email}) async {
    if (id == null && email == null) {
      throw ArgumentError('Devi fornire un ID o un\'email.');
    }
    Map<String, dynamic>? userData;
    if (email != null) {
      userData = await findUserByEmail(email);
    } else if (id != null) {
      userData = await findUserById(id);
    }

    if (userData == null) return false;
    return userData['isVerified'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> createUser(
      Map<String, dynamic> userData, {
        required String collection,
      }) async {
    final email = userData['email'] as String;
    if (_simulatedDatabase.containsKey(email)) {
      throw Exception('Utente già esistente');
    }
    final int newId = _simulatedDatabase.length + 300;
    userData['id'] = newId;
    _simulatedDatabase[email] = userData;
    return userData;
  }

  Future<void> saveOtp(String telefono, String otp) async {
    _otpCache[telefono] = otp;
  }

  Future<bool> verifyOtp(String telefono, String otp) async {
    final storedOtp = _otpCache[telefono];
    _otpCache.remove(telefono);
    return storedOtp == otp;
  }

  Future<void> markUserAsVerified(String email) async {
    if (_simulatedDatabase.containsKey(email.toLowerCase())) {
      _simulatedDatabase[email.toLowerCase()]!['isVerified'] = true;
    }
  }

  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    if (newUser.email == null) throw Exception('Email mancante.');
    final newId = _simulatedDatabase.length + 1000;
    final userData = newUser.toJson();
    userData['id'] = newId;

    final UtenteGenerico userWithId;
    if (userData['email'].toString().toLowerCase().endsWith('@soccorritore.gmail')) {
      userWithId = Soccorritore.fromJson(userData);
    } else {
      userWithId = Utente.fromJson(userData);
    }
    _simulatedDatabase[userWithId.email!.toLowerCase()] = userWithId.toJson();
    return userWithId;
  }

  // --- NUOVA SEZIONE: METODI DI SUPPORTO PER PROFILE SERVICE ---
  // Questi metodi estendono il Repository per gestire le operazioni richieste dal profilo
  // che non erano coperte dalla logica di Login.

  /// Recupera un utente tramite ID numerico.
  /// Essenziale perché il nuovo ProfileService lavora con int ID, mentre la mappa è basata su email.
  Future<Map<String, dynamic>?> findUserById(int id) async {
    return _simulatedDatabase.values.firstWhereOrNull(
          (user) => user['id'] == id,
    );
  }

  /// Aggiornamento "Bulk": prende una mappa di campi (es. nome, cognome, città) e li aggiorna tutti insieme.
  Future<void> updateUserGeneric(int id, Map<String, dynamic> updates) async {
    final key = _findKeyById(id);
    if (key != null) {
      updates.forEach((field, value) {
        _simulatedDatabase[key]![field] = value;
      });
      print("Aggiornati campi generici per ID $id: $updates");
    } else {
      throw Exception("Utente con ID $id non trovato per l'aggiornamento.");
    }
  }

  /// Aggiornamento mirato di un singolo campo (es. sovrascrivere l'intero oggetto 'permessi' o 'condizioni').
  Future<void> updateUserField(int id, String fieldName, dynamic value) async {
    final key = _findKeyById(id);
    if (key != null) {
      _simulatedDatabase[key]![fieldName] = value;
      print("Aggiornato campo '$fieldName' per ID $id");
    } else {
      throw Exception("Utente non trovato.");
    }
  }

  /// Gestione Liste (Simula arrayUnion): Aggiunge un item (es. allergia) se la lista esiste, altrimenti la crea.
  Future<void> addToArrayField(int id, String fieldName, dynamic item) async {
    final key = _findKeyById(id);
    if (key != null) {
      if (_simulatedDatabase[key]![fieldName] == null) {
        _simulatedDatabase[key]![fieldName] = [];
      }
      List<dynamic> list = _simulatedDatabase[key]![fieldName];
      list.add(item);
      print("Aggiunto a '$fieldName' per ID $id: $item");
    }
  }

  /// Gestione Liste (Simula arrayRemove): Rimuove un item dalla lista.
  Future<void> removeFromArrayField(int id, String fieldName, dynamic item) async {
    final key = _findKeyById(id);
    if (key != null) {
      List<dynamic>? list = _simulatedDatabase[key]![fieldName];
      if (list != null) {
        // HACK TECNICO: Dato che lavoriamo in memoria e le istanze degli oggetti (Maps)
        // possono essere diverse, usiamo jsonEncode per confrontare il contenuto e rimuovere quello giusto.
        final itemJson = jsonEncode(item);
        list.removeWhere((element) => jsonEncode(element) == itemJson);
        print("Rimosso da '$fieldName' per ID $id: $item");
      }
    }
  }

  /// Cancella fisicamente l'utente dalla mappa.
  Future<bool> deleteUser(int id) async {
    final key = _findKeyById(id);
    if (key != null) {
      _simulatedDatabase.remove(key);
      print("Utente ID $id eliminato dal DB.");
      return true;
    }
    return false;
  }

  // Helper interno per trovare la chiave (email) partendo dall'ID.
  String? _findKeyById(int id) {
    for (var entry in _simulatedDatabase.entries) {
      if (entry.value['id'] == id) {
        return entry.key;
      }
    }
    return null;
  }
}