import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'URL não definida';

  // Função para realizar login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Salvar o token nos SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', responseBody['token']);
        return responseBody;
      } else {
        return {'error': 'Erro ao autenticar: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'Erro ao conectar ao servidor'};
    }
  }

  // Função para realizar logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/auth/logout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Erro ao realizar logout: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'Erro ao conectar ao servidor'};
    }
  }
}
