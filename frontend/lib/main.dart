import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

// 2. Definisci il canale Android NUOVO (V3)
// Cambiando l'ID in 'emergency_channel_v3', forziamo Android a ricreare le impostazioni audio da zero.
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'emergency_channel_v3', // <--- ID NUOVO: V3
  'Allerte di Emergenza',
  description: 'Mostra le notifiche per le emergenze in arrivo',
  importance: Importance.max, // MAX è fondamentale per far apparire il banner e suonare
  playSound: true,
  enableVibration: true,
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
  AndroidInitializationSettings('@mipmap/ic_launcher');

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
    },
  );

  // 4. GESTIONE CANALI (Pulizia e Creazione)
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  if (androidPlugin != null) {
    // A. Cancella i vecchi canali che potrebbero essere buggati o silenziosi
    await androidPlugin.deleteNotificationChannel('emergency_channel');
    await androidPlugin.deleteNotificationChannel('emergency_channel_v2');

    // B. Crea il NUOVO canale V3
    await androidPlugin.createNotificationChannel(channel);
  }

  // 5. Opzioni per iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
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
    _setupForegroundNotifications();
  }

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

      if (notification != null && android != null) {
        // ID univoco basato sul tempo (remainder assicura che stia in un int32)
        final int uniqueId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        flutterLocalNotificationsPlugin.show(
          uniqueId,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id, // Usa 'emergency_channel_v3'
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',

              // --- IMPOSTAZIONI CRITICHE PER IL SUONO ---
              importance: Importance.max,
              priority: Priority.max, // Priority MAX per saltare le code
              playSound: true,
              enableVibration: true,

              // Questo forza la notifica a "rompere" il silenzio di un aggiornamento
              ticker: 'Nuova Emergenza!',
              category: AndroidNotificationCategory.alarm, // Trattalo come una sveglia/allarme
              visibility: NotificationVisibility.public,

              // Impedisce di raggruppare visivamente (e silenziare)
              // Usando un ID univoco anche qui, Android le tratta come entità separate
              groupKey: uniqueId.toString(),

              // Forza il suono anche se sembra un aggiornamento
              onlyAlertOnce: false,

              styleInformation: BigTextStyleInformation(
                notification.body ?? '',
              ),
            ),
          ),
          payload: message.data['type'],
        );
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'emergency_alert') {
      print("Naviga alla pagina emergenze");
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