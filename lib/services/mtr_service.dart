import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MTRService {
  Future<Map<String, String>> _getFepamCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString('fepamLogin') ?? '';
    final password = prefs.getString('fepamPassword') ?? '';
    final cnp = prefs.getString('fepamCnpj') ?? '';

    return {
      'login': login,
      'senha': password,
      'cnp': cnp,
    };
  }

  final String baseUrl = dotenv.env['API_URL'] ?? 'URL não definida';

  String getCodigoKey(String endpoint) {
    switch (endpoint) {
      case 'acondicionamento':
      case 'tecnologia':
        return 'tipoCodigo';
      case 'classe':
        return 'tpclaCodigo';
      case 'estadoFisico':
        return 'tpestCodigo';
      case 'unidade':
        return 'tpuniCodigo';
      case 'residuo':
        return 'tpre3Numero';
      default:
        return '';
    }
  }

  Future<List<Map<String, dynamic>>> fetchOptions(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final credentials = await _getFepamCredentials();

    final response = await http.post(
      Uri.parse('$baseUrl/api/mtr/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(credentials),
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> options =
          List<Map<String, dynamic>>.from(json.decode(response.body));

      // Obtendo a chave do código conforme o endpoint
      String codigoKey = getCodigoKey(endpoint);

      // Ordenando a lista conforme a chave do código
      options.sort((a, b) {
        final codigoA =
            a[codigoKey] != null ? int.tryParse(a[codigoKey].toString()) : 0;
        final codigoB =
            b[codigoKey] != null ? int.tryParse(b[codigoKey].toString()) : 0;
        return (codigoA ?? 0).compareTo(codigoB ?? 0);
      });

      return options;
    } else {
      throw Exception('Failed to load $endpoint');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAcondicionamento() =>
      fetchOptions('acondicionamento');
  Future<List<Map<String, dynamic>>> fetchClasse() => fetchOptions('classe');
  Future<List<Map<String, dynamic>>> fetchEstadoFisico() =>
      fetchOptions('estadoFisico');
  Future<List<Map<String, dynamic>>> fetchResiduo() => fetchOptions('residuo');
  Future<List<Map<String, dynamic>>> fetchTecnologia() =>
      fetchOptions('tecnologia');
  Future<List<Map<String, dynamic>>> fetchUnidade() => fetchOptions('unidade');

  Future<List<Map<String, dynamic>>> salvarManifestoLote(Map<String, dynamic> manifestoData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken') ?? '';
    final credentials = await _getFepamCredentials();
            
    final url = Uri.parse(
      '$baseUrl/api/mtr'
    );

    final requestData = {
      'login': credentials['login'],
      'senha': credentials['senha'],
      'cnp': credentials['cnp'],
      'manifestoJSONDtos': manifestoData['manifestoJSONDtos'],
    };

    print(requestData);
    print(manifestoData);
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        // Garantir que a resposta seja tratada como uma lista
        if (response.body.isEmpty) {
          return [];
        }
        
        final dynamic decodedResponse = json.decode(response.body);
        
        if (decodedResponse is List) {
          return List<Map<String, dynamic>>.from(decodedResponse);
        } else if (decodedResponse is Map) {
          return [decodedResponse as Map<String, dynamic>];
        } else {
          throw Exception('Formato de resposta inesperado');
        }
      } else {
        throw Exception('Falha ao salvar manifesto: ${response.body} (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erro ao salvar manifesto: $e');
    }
  }
}
