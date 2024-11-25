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
  }
  
  void _navigateToMainView() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22C55E),
      body: Center(
        child: Container(
          // Container for the white frame
          padding: const EdgeInsets.all(24.0),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              ),
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
                  await _presenter.login(
                      emailController.text, passwordController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                      0xFF22C55E),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<String>(
                valueListenable: messageNotifier,
                builder: (context, message, child) {
                  return Text(message,
                      style: const TextStyle(color: Colors.red));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
