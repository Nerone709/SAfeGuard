import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart'; // Fondamentale per interagire con il DB

class VerificationController {

  // Headers standard
  final Map<String, String> _headers = {'content-type': 'application/json'};

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

      // 2. Parsing Input (Ora ci aspettiamo email e code)
      final Map<String, dynamic> requestData = jsonDecode(body);

      // NOTA: AuthRepository manda 'code', non 'otp'.
      final String? email = requestData['email'];
      final String? code = requestData['code'];

      if (email == null || code == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Email e Codice sono obbligatori.'
          }),
          headers: _headers,
        );
      }

      // 3. Verifica su Firestore
      // Cerchiamo il documento nella collection 'email_verifications' con ID = email
      final verifyDocRef = Firestore.instance.collection('email_verifications').document(email);

      // Controlliamo se esiste
      final bool docExists = await verifyDocRef.exists;

      if (!docExists) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Nessuna richiesta di verifica trovata per questa email (o scaduta).',
          }),
          headers: _headers,
        );
      }

      final verifyDoc = await verifyDocRef.get();
      final String serverOtp = verifyDoc['otp'];

      // 4. Confronto Codici
      if (serverOtp == code) {
        // --- SUCCESSO ---

        // A. Attiviamo l'utente nella collection 'utenti' (o 'users')
        // Dobbiamo trovare l'utente con questa email
        final usersQuery = await Firestore.instance.collection('utenti').where('email', isEqualTo: email).get();

        if (usersQuery.isNotEmpty) {
          final userDoc = usersQuery.first;
          // Aggiorniamo lo stato dell'utente
          await Firestore.instance.collection('utenti').document(userDoc.id).update({
            'attivo': true,
            'email_verified': true,
          });
        }

        // B. Cancelliamo l'OTP usato (per sicurezza e pulizia)
        await verifyDocRef.delete();

        return Response.ok(
          jsonEncode({
            'success': true,
            'message': 'Verifica riuscita. Utente attivato.',
          }),
          headers: _headers,
        );

      } else {
        // --- FALLIMENTO ---
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'message': 'Codice OTP errato.',
          }),
          headers: _headers,
        );
      }

    } on FormatException {
      return Response.badRequest(
        body: jsonEncode({'success': false, 'message': 'Formato JSON non valido'}),
        headers: _headers,
      );
    } catch (e) {
      print('Errore VerificationController: $e');
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Errore interno del server: $e'}),
        headers: _headers,
      );
    }
  }
}