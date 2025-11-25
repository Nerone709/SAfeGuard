import 'dart:convert';
import 'package:shelf/shelf.dart'; // Import fondamentale
import '../services/RegisterService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';
import '../repositories/UserRepository.dart';

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart'; // Aggiunto per cast sicuri

class RegisterController {
  // Iniezione delle dipendenze (come nel tuo codice originale)
  final RegisterService _registerService = RegisterService(
    UserRepository(),
    VerificationService(UserRepository(), SmsService()),
  );

  // Headers standard
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Metodo aggiornato per Shelf
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

      // 2. Estrazione e Pulizia Password
      final password = requestData['password'] as String?;
      final confermaPassword = requestData['confermaPassword'] as String?;

      // Rimuoviamo i campi password dalla mappa prima di passarla al service
      requestData.remove('password');
      requestData.remove('confermaPassword');

      // --- VALIDAZIONE ---

      if (password == null || confermaPassword == null) {
        return _badRequest('Password e Conferma Password sono obbligatorie');
      }

      // A. Controllo uguaglianza
      if (password != confermaPassword) {
        return _badRequest('Le password non coincidono');
      }

      // B. Controllo Lunghezza (min 8, max 12 come da tua richiesta)
      if (password.length < 8 || password.length > 12) {
        return _badRequest('La password deve essere tra 8 e 12 caratteri');
      }

      // C. Controllo Lettera Maiuscola
      if (!password.contains(RegExp(r'[A-Z]'))) {
        return _badRequest('La password deve contenere almeno una lettera maiuscola');
      }

      // D. Controllo Numero
      if (!password.contains(RegExp(r'[0-9]'))) {
        return _badRequest('La password deve contenere almeno un numero');
      }

      // E. Controllo Carattere Speciale
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return _badRequest('La password deve contenere almeno un carattere speciale');
      }

      // --- FINE VALIDAZIONE ---

      // 3. Chiamata al Service
      final UtenteGenerico user = await _registerService.register(requestData, password);

      // 4. Costruzione Risposta
      String tipoUtente;
      // Gestione sicura dell'ID (default a 0 se null per evitare crash)
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
        'message': 'Registrazione avvenuta con successo. Tipo: $tipoUtente, ID: $assegnatoId',
        'user': user.toJson()..remove('passwordHash'),
      };

      return Response.ok(jsonEncode(responseBody), headers: _headers);

    } on FormatException {
      // Errore nel JSON in ingresso
      return _badRequest('Formato JSON non valido');
    } on Exception catch (e) {
      // Eccezioni di business lanciate dal Service (es. Email già in uso)
      // Rimuoviamo il prefisso "Exception: " se presente
      final msg = e.toString().replaceFirst('Exception: ', '');
      return _badRequest(msg);
    } catch (e) {
      // Errori imprevisti
      print('Errore RegisterController: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Errore interno del server'}),
        headers: _headers,
      );
    }
  }

  // Helper per risposte 400 Bad Request
  Response _badRequest(String message) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }
}