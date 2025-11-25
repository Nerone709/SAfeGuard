import 'dart:convert';
import 'package:shelf/shelf.dart'; // Import fondamentale per Shelf
import '../services/LoginService.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';

class LoginController {
  final LoginService _loginService = LoginService();

  // Headers standard per le risposte JSON
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // 1. Login classico (Email/Telefono + Password)
  Future<Response> handleLoginRequest(Request request) async {
    try {
      // Lettura e validazione body
      final String body = await request.readAsString();
      if (body.isEmpty) return _buildErrorResponse(400, 'Body della richiesta vuoto');

      final Map<String, dynamic> credentials = jsonDecode(body);

      final email = credentials['email'] as String?;
      final telefono = credentials['telefono'] as String?;
      final password = credentials['password'] as String?;

      if ((email == null && telefono == null) || password == null) {
        return _buildErrorResponse(400, 'Email/Telefono e Password sono obbligatori.');
      }

      // Chiamata al Service
      final result = await _loginService.login(
        email: email,
        telefono: telefono,
        password: password,
      );

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(
          401, // Unauthorized
          'Credenziali non valide (combinazione errata o utente non trovato)',
        );
      }
    } on FormatException {
      return _buildErrorResponse(400, 'JSON non valido');
    } catch (e) {
      return _buildErrorResponse(500, 'Errore interno del server: $e');
    }
  }

  // 2. Login con Google
  Future<Response> handleGoogleLoginRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _buildErrorResponse(400, 'Body vuoto');

      final Map<String, dynamic> payload = jsonDecode(body);
      final googleToken = payload['id_token'] as String?;

      if (googleToken == null || googleToken.isEmpty) {
        return _buildErrorResponse(400, 'Token Google mancante nella richiesta.');
      }

      final result = await _loginService.loginWithGoogle(googleToken);

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(401, 'Autenticazione Google fallita.');
      }
    } catch (e) {
      return _buildErrorResponse(500, 'Errore durante il login Google: $e');
    }
  }

  // 3. Login con Apple
  Future<Response> handleAppleLoginRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _buildErrorResponse(400, 'Body vuoto');

      final Map<String, dynamic> payload = jsonDecode(body);

      final identityToken = payload['identityToken'] as String?;
      final email = payload['email'] as String?;
      final firstName = payload['givenName'] as String?;
      final lastName = payload['familyName'] as String?;

      if (identityToken == null || identityToken.isEmpty) {
        return _buildErrorResponse(400, 'Token Apple (identityToken) mancante.');
      }

      final result = await _loginService.loginWithApple(
        identityToken: identityToken,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(401, 'Autenticazione Apple fallita.');
      }
    } catch (e) {
      return _buildErrorResponse(500, 'Errore durante il login Apple: $e');
    }
  }

  // --- HELPER METHODS ---

  // Costruzione Risposta di Successo (200 OK)
  Response _buildSuccessResponse(Map<String, dynamic> result) {
    // Gestione sicura del casting: se 'user' non è UtenteGenerico, gestisci l'errore o fallo nel service
    // Assumo che LoginService ritorni la mappa {'user': UtenteGenerico, 'token': String}
    final user = result['user'] as UtenteGenerico;
    final token = result['token'] as String;

    String tipoUtente;
    int assignedId = user.id ?? 0;

    if (user is Soccorritore) {
      tipoUtente = 'Soccorritore';
    } else if (user is Utente) {
      tipoUtente = 'Utente Standard';
    } else {
      tipoUtente = 'Generico';
    }

    final responseBody = {
      'success': true,
      'message': 'Login avvenuto con successo. Tipo: $tipoUtente, ID: $assignedId',
      'user': user.toJson()..remove('passwordHash'), // Rimuove dati sensibili
      'token': token,
    };

    return Response.ok(jsonEncode(responseBody), headers: _headers);
  }

  // Costruzione Risposta di Errore (400, 401, 500)
  Response _buildErrorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }
}