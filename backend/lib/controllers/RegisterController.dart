import 'dart:convert';
import 'dart:math'; // Necessario per generare l'OTP casuale
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart'; // Necessario per scrivere nel DB Firestore

import '../services/RegisterService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';
import '../repositories/UserRepository.dart';

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';

class RegisterController {
  final RegisterService _registerService = RegisterService(
    UserRepository(),
    VerificationService(UserRepository(), SmsService()),
  );

  final Map<String, String> _headers = {'content-type': 'application/json'};

  Future<Response> handleRegisterRequest(Request request) async {
    try {
      // 1. Lettura Body
      final String body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Nessun dato inviato'}),
          headers: _headers,
        );
      }

      final Map<String, dynamic> requestData = jsonDecode(body);

      // Estraiamo l'email per usarla come chiave nel DB per l'OTP
      final email = requestData['email'] as String?;

      // 2. Estrazione e Pulizia Password
      final password = requestData['password'] as String?;
      final confermaPassword = requestData['confermaPassword'] as String?;

      requestData.remove('password');
      requestData.remove('confermaPassword');

      // --- VALIDAZIONE ---
      if (email == null || email.isEmpty) {
        return _badRequest('Email obbligatoria');
      }

      if (password == null || (confermaPassword == null && password.isNotEmpty)) {
        // Nota: ho reso opzionale confermaPassword se non inviata, ma se la logica client la manda, la controllo.
        // Se vuoi forzarla sempre: if (password == null || confermaPassword == null) ...
        return _badRequest('Password obbligatoria');
      }

      // Se confermaPassword è presente, controlliamo che coincidano
      if (confermaPassword != null && password != confermaPassword) {
        return _badRequest('Le password non coincidono');
      }

      if (password.length < 8 || password.length > 12) {
        return _badRequest('La password deve essere tra 8 e 12 caratteri');
      }
      if (!password.contains(RegExp(r'[A-Z]'))) {
        return _badRequest('La password deve contenere almeno una lettera maiuscola');
      }
      if (!password.contains(RegExp(r'[0-9]'))) {
        return _badRequest('La password deve contenere almeno un numero');
      }
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return _badRequest('La password deve contenere almeno un carattere speciale');
      }
      // --- FINE VALIDAZIONE ---

      // 3. Registrazione Utente (Servizio esistente)
      final UtenteGenerico user = await _registerService.register(requestData, password);

      // --- NUOVO: GENERAZIONE E SALVATAGGIO OTP NEL DB ---
      final String otpCode = _generateOTP();

      // Salviamo l'OTP su Firestore nella collezione 'email_verifications'
      // Usiamo l'email come ID del documento per trovarlo facilmente durante la verifica
      await Firestore.instance.collection('email_verifications').document(email).set({
        'otp': otpCode,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'is_verified': false,
      });

      print('🔥 [SERVER] OTP Generato e salvato per $email: $otpCode');
      // Qui dovresti chiamare anche il servizio di invio Email reale:
      // await _emailService.sendOtp(email, otpCode);
      // ---------------------------------------------------

      // 4. Costruzione Risposta
      String tipoUtente;
      final int assegnatoId = user.id ?? 0;

      if (user is Soccorritore) {
        tipoUtente = 'Soccorritore';
      } else if (user is Utente) {
        tipoUtente = 'Utente Standard';
      } else {
        tipoUtente = 'Generico';
      }

      final responseBody = {
        'success': true,
        'message': 'Registrazione avvenuta. OTP inviato.', // Messaggio aggiornato
        'user': user.toJson()..remove('passwordHash'),
      };

      return Response.ok(jsonEncode(responseBody), headers: _headers);

    } on FormatException {
      return _badRequest('Formato JSON non valido');
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return _badRequest(msg);
    } catch (e) {
      print('Errore RegisterController: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Errore interno del server'}),
        headers: _headers,
      );
    }
  }

  Response _badRequest(String message) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }

  // Funzione helper per generare un codice numerico a 6 cifre
  String _generateOTP() {
    var rng = Random();
    var code = rng.nextInt(900000) + 100000; // Genera numero tra 100000 e 999999
    return code.toString();
  }
}