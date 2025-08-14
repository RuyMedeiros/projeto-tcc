import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Para inicializar o Firebase
import 'package:firebase_messaging/firebase_messaging.dart'; // Para FCM
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Para notificações locais
import 'package:firebase_auth/firebase_auth.dart'; // Para Firebase Authentication
import 'screens/auth/login_screen.dart'; // Importando a tela de login
import 'core/utils/notification_service.dart'; // Importando o serviço de notificações

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa o Firebase

  // Inicializar notificações locais
  NotificationService notificationService = NotificationService();
  await notificationService.initializeNotifications();

  // Exibir a notificação diária para a pílula
  await notificationService.showDailyNotification();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendário Feminino',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance
            .authStateChanges(), // Verifica o estado de autenticação
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Se o usuário estiver logado, vai para a HomeScreen
            if (snapshot.hasData) {
              return HomeScreen(); // Carrega a tela principal (HomeScreen)
            } else {
              // Caso contrário, vai para a LoginScreen
              return LoginScreen(); // Carrega a tela de login
            }
          }
          // Enquanto a conexão está sendo feita, mostra um carregando
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // Solicitar permissões para notificações (para Android)
    _firebaseMessaging.requestPermission();

    // Inicializar as notificações locais
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Obter o token FCM
    _firebaseMessaging.getToken().then((String? token) {
      print("Token FCM: $token");
    });

    // Ouvir as notificações recebidas
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.title}');
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          channelDescription: 'your_channel_description',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendário Feminino')),
      body: Center(child: Text('Notificações Push no Flutter')),
    );
  }
}
