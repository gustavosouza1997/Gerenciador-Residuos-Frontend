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
  Future<void> createResiduo(Map<String, dynamic> pessoaData) async {
    messageNotifier.value = 'Criando pessoa...';

    final result = await pessoaService.createPessoa(pessoaData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Pessoa criada com sucesso';
    }
  }

  // Listar resíduos enviados
  Future<void> loadAllResiduos() async {
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
  Future<void> updateResiduo(String id, Map<String, dynamic> updatedData) async {
    messageNotifier.value = 'Atualizando pessoa...';

    final result = await pessoaService.updatePessoa(id, updatedData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Pessoa atualizado com sucesso';
    }
  }

  // Excluir um resíduo
  Future<void> deleteResiduo(String id) async {
    messageNotifier.value = 'Excluindo pessoa...';

    final result = await pessoaService.deletePessoa(id);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Resíduo excluído com sucesso';
      loadAllResiduos();
    }
  }
}
