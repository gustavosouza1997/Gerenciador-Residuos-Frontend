// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FepamForm extends StatefulWidget {
  const FepamForm({super.key});

  @override
  State<FepamForm> createState() => _FepamFormState();
}

class _FepamFormState extends State<FepamForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();

  Future<void> _saveCredentials() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fepamLogin', _loginController.text);
      await prefs.setString('fepamPassword', _passwordController.text);
      await prefs.setString('fepamCnpj', _cnpjController.text);
      await prefs.setBool('isFepamConfigured', true);

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF22C55E),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo_fepam.png',
                    width: 200,
                    height: 200,
                  ),
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(labelText: 'Login'),
                    validator: (value) =>
                        value!.isEmpty ? 'Por favor, insira o login' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Por favor, insira a senha' : null,
                  ),
                  TextFormField(
                    controller: _cnpjController,
                    decoration: const InputDecoration(labelText: 'CNPJ'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Por favor, insira o CNPJ' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveCredentials,
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
