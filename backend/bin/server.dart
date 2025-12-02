import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:firedart/firedart.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:backend/controllers/login_controller.dart';
import 'package:backend/controllers/register_controller.dart';
import 'package:backend/controllers/verification_controller.dart';
import 'package:backend/controllers/profile_controller.dart';
import 'package:backend/controllers/auth_guard.dart';
import 'package:backend/controllers/emergenze_controller.dart';

void main() async {
  // 1. Configurazione ambiente
  var env = DotEnv(includePlatformEnvironment: true)..load();
  final portStr = Platform.environment['PORT'] ?? env['PORT'] ?? '8080';
  final int port = int.parse(portStr);

  final projectId =
      Platform.environment['FIREBASE_PROJECT_ID'] ?? env['FIREBASE_PROJECT_ID'];

  if (projectId == null) {
    print('❌ ERRORE CRITICO: Variabile FIREBASE_PROJECT_ID mancante.');
    exit(1);
  }

  // 2. DataBase
  Firestore.initialize(projectId);
  print('🔥 Firestore inizializzato: $projectId');

  // 3. Controllers
  final loginController = LoginController();
  final registerController = RegisterController();
  final verifyController = VerificationController();
  final profileController = ProfileController();
  final authGuard = AuthGuard();
  final emergenzeController = EmergenzeController();

  // 4. Routing pubblico
  final app = Router();

  app.post('/api/auth/login', loginController.handleLoginRequest);
  app.post('/api/auth/google', loginController.handleGoogleLoginRequest);
  app.post('/api/auth/apple', loginController.handleAppleLoginRequest);
  app.post('/api/auth/register', registerController.handleRegisterRequest);
  app.post('/api/verify', verifyController.handleVerificationRequest);
  app.get('/health', (Request request) => Response.ok('OK'));

  // 5. Routing Protetto (Profilo Utente)
  final profileApi = Router();

  // Lettura dati
  profileApi.get('/', profileController.getProfile);

  // Modifica dati
  profileApi.put('/anagrafica', profileController.updateAnagrafica);
  profileApi.put('/permessi', profileController.updatePermessi);
  profileApi.put('/condizioni', profileController.updateCondizioni);
  profileApi.put('/notifiche', profileController.updateNotifiche);
  profileApi.put('/password', profileController.updatePassword);

  // Gestione Dispositivo e Posizione
  profileApi.post('/device/token', profileController.updateFCMToken);
  profileApi.post('/position', profileController.updatePosition);

  // Aggiunta elementi a liste
  profileApi.post('/allergie', profileController.addAllergia);
  profileApi.post('/medicinali', profileController.addMedicinale);
  profileApi.post('/contatti', profileController.addContatto);

  // Rimozione elementi o cancellazione account
  profileApi.delete('/allergie', profileController.removeAllergia);
  profileApi.delete('/medicinali', profileController.removeMedicinale);
  profileApi.delete('/contatti', profileController.removeContatto);
  profileApi.delete('/', profileController.deleteAccount);

  // Router per le Segnalazioni (Placeholder per ora)
  final reportApi = Router();

  // 6. Mounting & Middleware

  // Mount Profilo
  app.mount(
    '/api/profile',
    Pipeline().addMiddleware(authGuard.middleware).addHandler(profileApi.call),
  );

  // Mount Reports
  app.mount(
    '/api/reports',
    Pipeline().addMiddleware(authGuard.middleware).addHandler(reportApi.call),
  );

  // Router Emergenze (SOS)
  final emergenzeRouter = Router()
    ..post('/sos', emergenzeController.handleSOSRequest);

  // Mount Emergenze
  app.mount(
    '/api/emergenze',
    Pipeline()
        .addMiddleware(authGuard.middleware)
        .addHandler(emergenzeRouter.call),
  );

  // 7. Pipeline Server e Configurazione CORS
  final corsMiddleware = corsHeaders(
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': '*',
    },
  );

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware)
      .addHandler(app.call);

  // 8. Avvio Server
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);

  print('🚀 Server in ascolto su http://${server.address.host}:${server.port}');
}
