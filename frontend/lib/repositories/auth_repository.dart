import 'dart:async';

class AuthRepository {
  /// Simula il Login con Email e Password
  /// In futuro qui userai: http.post('api/login', body: {...})
  Future<void> login(String email, String password) async {
    // 1. Simuliamo l'attesa della rete (2 secondi)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simuliamo un controllo (Backend finto)
    // Se l'email contiene "error", lanciamo un'eccezione per testare i messaggi rossi in UI
    if (email.contains("error")) {
      throw Exception("Credenziali non valide");
    }

    // Se tutto va bene, la funzione finisce senza errori (Successo)
    return;
  }

  /// Simula la Registrazione
  Future<void> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (password.length < 6) {
      throw Exception("Password troppo corta (min 6 caratteri)");
    }

    return;
  }

  /// Simula l'invio del codice SMS (OTP)
  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    // Qui chiameresti l'endpoint per inviare l'SMS reale
    return;
  }

  /// Simula la verifica del codice OTP inserito
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(seconds: 2));

    // Simuliamo che il codice corretto sia "123456"
    // Oppure accettiamo qualsiasi codice di 6 cifre per facilitare i test
    if (code.length == 6) {
      return true;
    } else {
      return false; // Codice errato
    }
  }
}