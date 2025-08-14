import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importando Firebase Authentication
import '../home/home_screen.dart'; // Importando a tela Home

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // Função de cadastro
  Future<void> _signUp() async {
    try {
      // Cria o usuário com email e senha
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // Se o cadastro for bem-sucedido, redireciona para a HomeScreen
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ), // Redireciona para a HomeScreen
        );
      }
    } catch (e) {
      print(e); // Exibe erro caso aconteça
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Senha'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: Text('Cadastrar')),
          ],
        ),
      ),
    );
  }
}
