import 'package:flutter/material.dart';
import '../services/pessoa_service.dart';

class PessoaPresenter {
  final PessoaService pessoaService;
  final ValueNotifier<String> messageNotifier;
  final ValueNotifier<List<dynamic>> pessoasNotifier;

  PessoaPresenter({
    required this.pessoaService,
    required this.messageNotifier,
    required this.pessoasNotifier,
  });

  // Criar uma pessoa
  Future<void> createPessoa(Map<String, dynamic> pessoaData) async {
    messageNotifier.value = 'Criando pessoa...';

    final result = await pessoaService.createPessoa(pessoaData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Pessoa criada com sucesso';
    }
  }

  // Listar resíduos enviados
  void loadAllPessoas() async {
    messageNotifier.value = 'Carregando pessoas...';

    final result = await pessoaService.getAllPessoas();

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      pessoasNotifier.value = result['pessoas'];
      messageNotifier.value = 'Pessoas carregadas com sucesso';
    }
  }

  // Atualizar um resíduo
  Future<void> updatePessoa(String id, Map<String, dynamic> updatedData) async {
    messageNotifier.value = 'Atualizando pessoa...';

    final result = await pessoaService.updatePessoa(id, updatedData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Pessoa atualizado com sucesso';
    }
  }

  // Excluir um resíduo
  Future<void> deletePessoa(String id) async {
    messageNotifier.value = 'Excluindo pessoa...';

    final result = await pessoaService.deletePessoa(id);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Resíduo excluído com sucesso';
      loadAllPessoas();
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getAllPessoas() async {
    try {
      final rawPessoas = await pessoaService.getAllPessoas();
      final pessoas = (rawPessoas['pessoas'] as List<dynamic>).map((item) {
        Map<String, dynamic> pessoaMap = {
          'id': item['id']?.toString() ?? '',
          'nome': (item['nome']?.toString() ??
              item['razaoSocial']?.toString() ??
              ''),
          'email': item['email']?.toString() ?? '',
          'telefone': item['telefone']?.toString() ?? '',
          'endereco': item['endereco']?.toString() ?? '',
          'municipio': item['municipio']?.toString() ?? '',
          'transportador': item['transportador'] ?? false,
          'gerador': item['gerador'] ?? false,
          'destinador': item['destinador'] ?? false,
          'motorista': item['motorista'] ?? false,
          'uf': item['uf']?.toString() ?? '',
        };

        if (item.containsKey('cpf')) {
          pessoaMap['cpf'] = item['cpf']?.toString() ?? '';
        } else if (item.containsKey('cnpj')) {
          pessoaMap['cnpj'] = item['cnpj']?.toString() ?? '';
        }

        return pessoaMap;
      }).toList();

      return {'pessoas': pessoas};
    } catch (e) {
      throw Exception('Erro ao carregar opções: $e');
    }
  }
}
