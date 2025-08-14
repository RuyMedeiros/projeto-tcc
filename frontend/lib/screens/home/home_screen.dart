import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para Firebase Authentication
import 'package:calendario_feminino/screens/calendar/calendar_screen.dart'; // Importando a tela do Calendário Menstrual
import 'package:calendario_feminino/screens/auth/login_screen.dart'; // Importando a tela de login

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Faz o logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ), // Redireciona para a tela de login
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Você está logado!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navegar para a tela do Calendário Menstrual
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreen(),
                  ), // Navega para o Calendário
                );
              },
              child: Text('Ver Calendário Menstrual'),
            ),
          ],
        ),
      ),
    );
  }
}
