import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ResiduoService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'URL não definida';

  // Método para criar um resíduo
  Future<Map<String, dynamic>> createResiduo(Map<String, dynamic> residuoData) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(residuoData),
    );

    return _processResponse(response);
  }

  // Método para obter todos os resíduos
  Future<Map<String, dynamic>> getAllResiduos() async {
    final response = await http.get(Uri.parse('$apiUrl/listar'));

    return _processResponse(response);
  }

  // Método para atualizar um resíduo
  Future<Map<String, dynamic>> updateResiduo(String id, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    return _processResponse(response);
  }

  // Método para obter resíduos não enviados
  Future<Map<String, dynamic>> getResiduosNaoEnviados() async {
    final response = await http.get(Uri.parse('$apiUrl/nao-enviados'));

    return _processResponse(response);
  }

  // Método para excluir um resíduo
  Future<Map<String, dynamic>> deleteResiduo(String id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
    );

    return _processResponse(response);
  }

  // Função para processar as respostas das requisições
  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {'error': 'Erro ao processar a requisição: ${response.statusCode}'};
    }
  }
}
