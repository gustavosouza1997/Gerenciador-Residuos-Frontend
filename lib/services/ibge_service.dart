import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IBGEService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'URL não definida';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getUFs() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiUrl/api/ibge'),
        headers: headers);

    return _processResponse(response);
  }

  Future<Map<String, dynamic>> getCities(String uf) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiUrl/api/ibge/$uf/municipios'),
        headers: headers);

    return _processResponse(response);
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {'error': 'Sucesso'};
      }
      try {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is List) {
          return {'pessoas': decodedResponse};
        } else if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else {
          return {'error': 'Resposta inesperada do servidor'};
        }
      } catch (e) {
        return {'error': 'Erro ao decodificar JSON: $e'};
      }
    } else {
      return {
        'error': 'Erro ao processar a requisição: ${response.statusCode}'
      };
    }
  }
}