import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Para interagir com o Firestore
import 'package:table_calendar/table_calendar.dart'; // Para o calendário menstrual
import 'package:calendario_feminino/core/utils/notification_service.dart'; // Importe o serviço de notificações

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<String>> _selectedEvents;
  late final DateTime _selectedDay;
  late final DateTime _focusedDay;

  Map<DateTime, List<String>> events = {}; // Para armazenar os eventos

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedEvents = ValueNotifier([]);
    _loadEvents(); // Carregar eventos do Firestore
    _notificationService.initializeNotifications(); // Inicializar notificações
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // Função para carregar eventos do Firestore (como o ciclo menstrual e a pílula)
  Future<void> _loadEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cycles')
        .get();
    snapshot.docs.forEach((doc) {
      DateTime startDate = (doc['start_date'] as Timestamp).toDate();
      DateTime endDate = (doc['end_date'] as Timestamp).toDate();

      // Adiciona os eventos ao mapa
      for (
        var date = startDate;
        date.isBefore(endDate.add(Duration(days: 1)));
        date = date.add(Duration(days: 1))
      ) {
        if (!events.containsKey(date)) {
          events[date] = [];
        }
        events[date]!.add('Ciclo Menstrual');
      }
    });

    setState(() {
      _selectedEvents.value = _getEventsForDay(_selectedDay);
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void _addPillEvent(DateTime day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tomar Pílula'),
        content: Text('Você tomou a pílula hoje?'),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('pills').add({
                'date': day,
                'user_id': FirebaseAuth.instance.currentUser?.uid,
                'pill_taken': true,
              });

              setState(() {
                events[day]?.add('Pílula Tomada');
                _selectedEvents.value = _getEventsForDay(day);
              });

              // Enviar notificação após o usuário marcar a pílula
              _notificationService.showDailyNotification();

              Navigator.of(context).pop();
            },
            child: Text('Sim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário Menstrual'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Lógica para enviar lembretes de pílula, se necessário
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
            },
            eventLoader: (day) {
              return _getEventsForDay(day);
            },
          ),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(events[index]));
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _addPillEvent(_selectedDay),
            child: Text('Marcar Tomada de Pílula'),
          ),
        ],
      ),
    );
  }
}
