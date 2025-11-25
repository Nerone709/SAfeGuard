import 'dart:convert';
import 'package:shelf/shelf.dart'; // Import necessario per Request/Response
import '../services/VerificationService.dart';
import '../repositories/UserRepository.dart';
import '../services/SmsService.dart';

class VerificationController {
  // Inizializzazione delle dipendenze
  final VerificationService _verificationService = VerificationService(
    UserRepository(),
    SmsService(),
  );

  // Headers standard per le risposte JSON
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Metodo aggiornato per accettare Request e ritornare Response
  Future<Response> handleVerificationRequest(Request request) async {
    try {
      // 1. Lettura del Body
      final String body = await request.readAsString();
      if (body.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'success': false, 'message': 'Body vuoto'}),
          headers: _headers,
        );
      }

      // 2. Parsing e Validazione Input
      final Map<String, dynamic> requestData = jsonDecode(body);
      final String? telefono = requestData['telefono'];
      final String? otp = requestData['otp'];

      if (telefono == null || otp == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Telefono e OTP sono campi obbligatori.'
          }),
          headers: _headers,
        );
      }

      // 3. Chiamata al Service
      final isVerified = await _verificationService.completePhoneVerification(
        telefono,
        otp,
      );

      // 4. Gestione Risposta
      if (isVerified) {
        // 200 OK
        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Verifica OTP riuscita. L\'utente è ora attivo.',
          }),
          headers: _headers,
        );
      } else {
        // 400 Bad Request (o 401) se l'OTP è errato
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Codice OTP non valido o scaduto.',
          }),
          headers: _headers,
        );
      }

    } on FormatException {
      // JSON malformato
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'Formato JSON non valido'}),
        headers: _headers,
      );
    } catch (e) {
      // Errore generico server
      print('Errore VerificationController: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Errore interno del server: $e'}),
        headers: _headers,
      );
    }
  }
}