import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // <--- AGGIUNTO
import 'package:frontend/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/providers/permission_provider.dart';
import 'package:frontend/ui/screens/auth/loading_screen.dart';
import 'package:frontend/providers/report_provider.dart';

// 1. Definisci il plugin per le notifiche locali (Globale)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// 2. Definisci il canale Android (IMPORTANTE: ID deve coincidere col backend)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'emergency_channel', // id
  'Allerte di Emergenza', // title
  description: 'Mostra le notifiche per le emergenze in arrivo', // description
  importance: Importance.max, // Max fa apparire il banner e suonare
  playSound: true,
);

// Handler per messaggi in background (deve essere top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Messaggio in background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp();

  // 3. Configurazione Iniziale Notifiche Locali
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Assicurati che l'icona esista

  // Configurazione iOS (richiesta permessi base)
  const DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      print("Notifica locale cliccata con payload: ${response.payload}");
      // Qui puoi gestire il click sulla notifica locale
    },
  );

  // 4. Crea il canale su Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 5. Opzioni per iOS (per mostrare notifiche in foreground nativamente su iOS)
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    // Utilizza MultiProvider per iniettare più Provider nell'albero dei widget
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicalProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const SAfeGuard(),
    ),
  );
}

class SAfeGuard extends StatefulWidget {
  const SAfeGuard({super.key});

  @override
  State<SAfeGuard> createState() => _SAfeGuardState();
}

class _SAfeGuardState extends State<SAfeGuard> {
  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
    _setupForegroundNotifications(); // <--- Avvia ascolto foreground
  }

  // Gestione apertura app da notifica (Background / Terminated)
  Future<void> _setupInteractedMessage() async {
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // 6. ASCOLTO IN FOREGROUND (App Aperta)
  void _setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Messaggio ricevuto in Foreground: ${message.notification?.title}");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Se c'è una notifica e siamo su Android, la costruiamo manualmente
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max, // Alta priorità
              priority: Priority.high,
              color: Colors.red, // Colore accento
              playSound: true,
            ),
          ),
          payload: message.data['type'], // Passa dati utili
        );
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'emergency_alert') {
      print("Naviga alla pagina emergenze");
      // Qui puoi implementare la navigazione tramite GlobalKey o Provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}