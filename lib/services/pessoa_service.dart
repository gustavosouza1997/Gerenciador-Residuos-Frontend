import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PessoaService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'URL não definida';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Método para criar uma pessoa
  Future<Map<String, dynamic>> createPessoa(
      Map<String, dynamic> pessoaData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$apiUrl/api/pessoa'),
      headers: headers,
      body: json.encode(pessoaData),
    );

    return _processResponse(response);
  }

  // Método para obter todos as pessoas
  Future<Map<String, dynamic>> getAllPessoas() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$apiUrl/api/pessoa/listar'),
        headers: headers);

    return _processResponse(response);
  }

  // Método para atualizar uma pessoa
  Future<Map<String, dynamic>> updatePessoa(
      String id, Map<String, dynamic> updatedData) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$apiUrl/api/pessoa/$id'),
      headers: headers,
      body: json.encode(updatedData),
    );

    return _processResponse(response);
  }

  // Método para excluir uma pessoa
  Future<Map<String, dynamic>> deletePessoa(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$apiUrl/api/pessoa/$id'),
        headers: headers);

    return _processResponse(response);
  }

  // Função para processar as respostas das requisições
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
