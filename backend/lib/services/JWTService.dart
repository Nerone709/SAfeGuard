import 'dart:convert';
import 'dart:io';

class JWTService {
  // Recupera la chiave dalle variabili d'ambiente
  String get _secret => Platform.environment['JWT_SECRET'] ?? 'FALLBACK_DEV_SECRET_DO_NOT_USE_IN_PROD';

  String generateToken(int userId, String userType) {
    final payload = {
      'id': userId,
      'type': userType,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    };

    final header = jsonEncode({'alg': 'HS256', 'typ': 'JWT'});
    final headerBase64 = base64Url.encode(utf8.encode(header));
    final payloadBase64 = base64Url.encode(utf8.encode(jsonEncode(payload))); // Fix: jsonEncode del payload

    // In un caso reale qui useresti HMAC-SHA256 con _secret
    final signature = base64Url.encode(utf8.encode('fake_signature_$_secret'));

    return '$headerBase64.$payloadBase64.$signature';
  }

  Map<String, dynamic>? verifyToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decodifica Payload
      final payloadString = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payload = jsonDecode(payloadString);

      // Qui dovresti verificare la firma ricalcolandola con _secret

      return payload;
    } catch (e) {
      return null;
    }
  }
}