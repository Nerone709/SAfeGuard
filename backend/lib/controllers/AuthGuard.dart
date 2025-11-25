import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/JWTService.dart';

class AuthGuard {
  final JWTService _jwtService = JWTService();

  /// Il middleware di Shelf
  Middleware get middleware => (Handler innerHandler) {
    return (Request request) async {
      // 1. Gestione pre-flight CORS (Opzionale, ma utile per frontend web)
      if (request.method == 'OPTIONS') {
        return await innerHandler(request);
      }

      // 2. Controllo Header Authorization
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return _unauthorizedResponse('Token di autorizzazione mancante o malformato.');
      }

      // 3. Estrazione e Verifica Token
      final token = authHeader.substring(7); // Rimuove 'Bearer '
      final payload = _jwtService.verifyToken(token);

      if (payload == null) {
        return _unauthorizedResponse('Token non valido o scaduto. Effettuare nuovamente il login.');
      }

      // 4. Context Injection (Thread-Safe)
      // Creiamo una nuova richiesta "arricchita" con i dati dell'utente.
      // I controller successivi potranno accedere a questi dati tramite request.context['user']
      final updatedRequest = request.change(context: {
        'user': {
          'id': payload['id'],
          'type': payload['type'],
          // Puoi aggiungere qui altri campi presenti nel payload del token
        }
      });

      // 5. Passa il controllo all'handler successivo con la richiesta aggiornata
      return await innerHandler(updatedRequest);
    };
  };

  // Helper per risposta 401 JSON standardizzata
  Response _unauthorizedResponse(String message) {
    return Response(
      401, // HTTP Status Code: Unauthorized
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}