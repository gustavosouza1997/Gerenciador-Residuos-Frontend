import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPresenter {
  final AuthService authService;
  final ValueNotifier<String> messageNotifier;
  final Function navigateToMainView;

  LoginPresenter({
    required this.authService,
    required this.messageNotifier,
    required this.navigateToMainView,
  });

  // Função de login
  Future<void> login(String email, String password) async {
    messageNotifier.value = 'Processando...';

    final result = await authService.login(email, password);
    // ignore: avoid_print
    print(result);
  
    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = result['message'];
      // Navegar para a MainView após o login bem-sucedido
      if (result['message'] == 'Login realizado com sucesso') {
        // Certifique-se de que a navegação está funcionando
        navigateToMainView();
      }
    }
  }

  // Função de logout
  Future<void> logout() async {
    final result = await authService.logout();

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = result['message'];
    }
  }
}
