import 'dart:convert';
import '../services/RegisterService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';
import '../repositories/UserRepository.dart';

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';

class RegisterController {
  final RegisterService _registerService = RegisterService(
    UserRepository(),
    VerificationService(UserRepository(), SmsService()),
  );

  // Simula la gestione di una richiesta HTTP POST /api/register
  Future<String> handleRegisterRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> requestData = jsonDecode(requestBodyJson);

      // 1. Recupero la password
      final password = requestData.remove('password') as String;

      // 2. Recupero la conferma password
      // Uso remove per pulire i dati prima di inviarli al service
      final confermaPassword = requestData.remove('confermaPassword');

      if (confermaPassword == null) {
        throw Exception('Il campo confermaPassword è obbligatorio');
      }

      // --- VALIDAZIONE PASSWORD ---

      // A. Controllo uguaglianza
      if (password != confermaPassword) {
        throw Exception('Le password non coincidono');
      }

      // B. Controllo Lunghezza (min 8, max 64)
      if (password.length < 8 || password.length > 12) {
        throw Exception(
          'La password deve essere lunga almeno 8 caratteri e non più di 12',
        );
      }

      // C. Controllo Lettera Maiuscola
      if (!password.contains(RegExp(r'[A-Z]'))) {
        throw Exception(
          'La password deve contenere almeno una lettera maiuscola',
        );
      }

      // D. Controllo Numero
      if (!password.contains(RegExp(r'[0-9]'))) {
        throw Exception('La password deve contenere almeno un numero');
      }

      // E. Controllo Carattere Speciale
      // Verifica la presenza di almeno un simbolo tra quelli elencati
      if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
        throw Exception(
          'La password deve contenere almeno un carattere speciale (es. !, @, #, \$, ecc.)',
        );
      }

      // --- FINE VALIDAZIONE ---

      // Il resto dei dati (inclusi email e telefono opzionali) va al service
      final user = await _registerService.register(requestData, password);

      // Controllo del tipo e recupero ID
      String tipoUtente;
      final int assegnatoId = user.id!;

      if (user is Soccorritore) {
        tipoUtente = 'Soccorritore';
      } else if (user is Utente) {
        tipoUtente = 'Utente Standard';
      } else {
        tipoUtente = 'Generico';
      }

      final responseBody = {
        'success': true,
        'message':
            'Registrazione avvenuta con successo. Tipo: $tipoUtente, ID assegnato: $assegnatoId',
        'user': user.toJson()..remove('passwordHash'),
      };
      return jsonEncode(responseBody);
    } on Exception catch (e) {
      final responseBody = {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
      return jsonEncode(responseBody);
    } catch (e) {
      final responseBody = {
        'success': false,
        'message': 'Errore interno del server durante la registrazione.',
      };
      return jsonEncode(responseBody);
    }
  }
}
