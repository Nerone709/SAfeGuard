import 'package:flutter/material.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  // --- STATO DELLA UI ---
  bool _isLoading = false;
  String? _errorMessage;

  // --- STATO DEL TIMER (Specifico per la verifica OTP) ---
  int _secondsRemaining = 30;
  Timer? _timer;

  // --- GETTERS (Per leggere i dati dalla UI) ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;

  // ----------------------------------------------------------------
  // 1. LOGICA LOGIN & REGISTRAZIONE (FITTIZIA)
  // ----------------------------------------------------------------

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    // Simulo attesa di rete di 2 secondi
    await Future.delayed(const Duration(seconds: 2));

    // LOGICA FINTA:
    // Se l'email contiene "error", simulo un fallimento.
    // Altrimenti faccio entrare l'utente.
    if (email.contains("error")) {
      _errorMessage = "Credenziali non valide (Simulazione)";
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true; // Successo
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);

    // Simulo attesa
    await Future.delayed(const Duration(seconds: 2));

    // LOGICA FINTA:
    if (password.length < 4) {
      _errorMessage = "Password troppo corta (min 4 caratteri)";
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return true;
  }

  // ----------------------------------------------------------------
  // 2. LOGICA OTP E TIMER (FITTIZIA)
  // ----------------------------------------------------------------

  // Invia il codice (o lo rinvia)
  Future<bool> sendPhoneCode(String phone) async {
    _setLoading(true);

    // Simulo invio SMS
    await Future.delayed(const Duration(seconds: 1));

    // Appena "inviato", faccio partire il timer
    startTimer();
    _setLoading(false);
    return true;
  }

  // Verifica il codice inserito dall'utente
  Future<bool> verifyCode(String code) async {
    _setLoading(true);

    // Simulo verifica server
    await Future.delayed(const Duration(seconds: 2));

    // LOGICA FINTA:
    // Accetto il codice solo se è "123456" oppure se è lungo 6 cifre (per comodità)
    // Cambia questa condizione come preferisci per i tuoi test.
    bool isValid = code == "123456" || code.length == 6;

    _setLoading(false);

    if (isValid) {
      stopTimer(); // Se è giusto, fermo il timer
      return true;
    } else {
      _errorMessage = "Codice errato (Prova 123456)";
      notifyListeners();
      return false;
    }
  }

  // --- GESTIONE TIMER ---
  void startTimer() {
    _secondsRemaining = 30; // Reset a 30 secondi
    _timer?.cancel(); // Cancella eventuali timer vecchi

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel(); // Ferma quando arriva a 0
      } else {
        _secondsRemaining--; // Scala 1 secondo
        notifyListeners(); // Avvisa la UI di aggiornare il testo
      }
    });
    notifyListeners(); // Aggiornamento iniziale
  }

  void stopTimer() {
    _timer?.cancel();
    _secondsRemaining = 0;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null; // Resetta errori vecchi
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}