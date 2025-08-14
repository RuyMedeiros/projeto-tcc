import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart'
    as tz; // Para carregar os dados de fusos horários

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicialização das notificações
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'app_icon',
        ); // Defina o ícone da notificação
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Inicializando os dados de fuso horário
    tz.initializeTimeZones();
  }

  // Função para exibir a notificação diária de pílula
  Future<void> showDailyNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'pill_channel', // ID do canal
          'Pílula Diária', // Nome do canal
          channelDescription:
              'Notificações diárias para lembrar de tomar a pílula',
          importance: Importance.high, // Nível de importância da notificação
          priority: Priority.high, // Prioridade da notificação
          ticker: 'ticker', // Texto de aviso
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // Exibe a notificação diária para lembrar de tomar a pílula, todos os dias às 8:00 AM
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      0, // ID da notificação
      'Lembrete de Pílula', // Título da notificação
      'Não esqueça de tomar sua pílula hoje!', // Corpo da notificação
      Time(8, 0, 0), // Hora para o lembrete (8:00 AM)
      notificationDetails, // Detalhes da notificação
    );
  }

  // Função para exibir a notificação de ciclo menstrual
  Future<void> showCycleNotification(DateTime cycleStartDate) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'cycle_channel', // ID do canal
          'Ciclo Menstrual', // Nome do canal
          channelDescription:
              'Notificação para lembrar do início do ciclo menstrual',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker', // Texto de aviso
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // Agendando a notificação para 1 dia antes do início do ciclo, às 8:00 AM
    DateTime notificationTime = DateTime(
      cycleStartDate.year,
      cycleStartDate.month,
      cycleStartDate.day - 1, // Um dia antes do ciclo
      8,
      0,
      0, // 8:00 AM
    );

    // Converta DateTime para TZDateTime
    final tz.TZDateTime tzDateTime = tz.TZDateTime.from(
      notificationTime,
      tz.local,
    );

    // Agendando a notificação para o início do ciclo (usando a função `zonedSchedule`)
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1, // ID da notificação
      'Lembrete de Ciclo', // Título da notificação
      'Seu próximo ciclo menstrual começa amanhã.', // Corpo da notificação
      tzDateTime, // Data e hora da notificação com TZDateTime
      notificationDetails, // Detalhes da notificação
      androidAllowWhileIdle:
          true, // Permite exibir enquanto o dispositivo está ocioso
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
