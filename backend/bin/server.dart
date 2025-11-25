import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'package:firedart/firedart.dart';

// Assicurati che i path dei package siano corretti nel tuo progetto
import 'package:backend/controllers/LoginController.dart';
import 'package:backend/controllers/RegisterController.dart';
import 'package:backend/controllers/VerificationController.dart';
import 'package:backend/controllers/AuthGuard.dart'; // Importa il Middleware

void main() async {
  // 1. Caricamento Variabili d'ambiente
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // 2. Configurazione Porta e Progetto Firebase
  final portStr = Platform.environment['PORT'] ?? env['PORT'] ?? '8080';
  final int port = int.parse(portStr);

  final projectId = Platform.environment['FIREBASE_PROJECT_ID'] ?? env['FIREBASE_PROJECT_ID'];

  if (projectId == null) {
    print('❌ ERRORE CRITICO: Variabile FIREBASE_PROJECT_ID mancante.');
    exit(1);
  }

  // 3. Inizializzazione Database
  Firestore.initialize(projectId);
  print('🔥 Firestore inizializzato: $projectId');

  // Inizializzazione Controller e Middleware
  final loginController = LoginController();
  final registerController = RegisterController();
  final verifyController = VerificationController();
  final authGuard = AuthGuard();

  // 4. Router
  final app = Router();

  // --- ROTTE PUBBLICHE (AUTH) ---

  // Login Classico
  // NOTA: Passiamo direttamente 'request' perché il controller ora gestisce Request -> Response
  app.post('/api/auth/login', (Request request) {
    return loginController.handleLoginRequest(request);
  });

  // Login Social (Aggiunti in base alle modifiche fatte al Controller)
  app.post('/api/auth/google', (Request request) {
    return loginController.handleGoogleLoginRequest(request);
  });

  app.post('/api/auth/apple', (Request request) {
    return loginController.handleAppleLoginRequest(request);
  });

  // Registrazione
  // IMPORTANTE: Assicurati di aver aggiornato RegisterController per accettare (Request request)
  // come abbiamo fatto per LoginController.
  app.post('/api/auth/register', (Request request) {
    return registerController.handleRegisterRequest(request);
  });

  // Verifica OTP
  // IMPORTANTE: Assicurati di aver aggiornato VerificationController per accettare (Request request)
  app.post('/api/verify', (Request request) {
    return verifyController.handleVerificationRequest(request);
  });

  // Health Check
  app.get('/health', (Request request) => Response.ok('OK'));


  // --- ROTTE PROTETTE (Esempio) ---
  // Definiamo un router separato per le rotte che richiedono il login
  final protectedApi = Router();

  protectedApi.get('/me', (Request request) {
    // Esempio: recupero dati utente iniettati da AuthGuard
    final user = request.context['user'];
    return Response.ok('Sei autenticato. Dati: $user');
  });

  // Montiamo il router protetto sotto /api/protected usando la Pipeline con AuthGuard
  app.mount('/api/protected/', Pipeline()
      .addMiddleware(authGuard.middleware) // <--- Protezione attiva qui
      .addHandler(protectedApi)
  );


  // 5. Configurazione Pipeline Principale (Logging + Routing)
  final handler = Pipeline()
      .addMiddleware(logRequests()) // Logga le richieste in console
      .addHandler(app);

  // 6. Avvio Server
  final server = await io.serve(
      handler,
      InternetAddress.anyIPv4, // Ascolta su 0.0.0.0
      port
  );

  print('🚀 Server in ascolto su http://${server.address.host}:${server.port}');
}