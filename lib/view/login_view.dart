import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../presenter/login_presenter.dart';
import 'main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<String> messageNotifier = ValueNotifier<String>('');

  late LoginPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(
      authService: AuthService(),
      messageNotifier: messageNotifier,
      navigateToMainView: _navigateToMainView,
      context: context,
    );

    // Verificar credenciais da FEPAM
    _presenter.checkFepamCredentials();
  }

  // Função para navegar para a tela MainView
  void _navigateToMainView() {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _presenter.login(emailController.text, passwordController.text);
              },
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<String>(
              valueListenable: messageNotifier,
              builder: (context, message, child) {
                return Text(message, style: const TextStyle(color: Colors.red));
              },
            ),
          ],
        ),
      ),
    );
  }
}
