// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../view/fepam_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginPresenter {
  final AuthService authService;
  final ValueNotifier<String> messageNotifier;
  final Function navigateToMainView;
  final BuildContext context;

  LoginPresenter({
    required this.authService,
    required this.messageNotifier,
    required this.navigateToMainView,
    required this.context,
  });

  Future<void> login(String email, String password) async {
    messageNotifier.value = 'Processando...';

    final result = await authService.login(email, password);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = result['message'];
      // Navegar para a MainView após o login bem-sucedido
      if (result['message'] == 'Login realizado com sucesso') {
        await checkFepamCredentials();
        navigateToMainView();
      }
    }
  }

  Future<void> logout() async {
    final result = await authService.logout();

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = result['message'];
    }
  }

  // Função para verificar credenciais da FEPAM
  Future<void> checkFepamCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final isConfigured = prefs.getBool('isFepamConfigured') ?? false;

    if (!isConfigured) {
      final success = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FepamForm()),
      );

      if (success != true) {
        Navigator.pop(context);
      }
    }
  }
}
