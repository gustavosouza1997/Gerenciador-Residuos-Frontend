import 'package:flutter/material.dart';
import '../services/residuo_service.dart';

class ResiduoPresenter {
  final ResiduoService residuoService;
  final ValueNotifier<String> messageNotifier;
  final ValueNotifier<List<dynamic>> residuosNotifier;

  ResiduoPresenter({
    required this.residuoService,
    required this.messageNotifier,
    required this.residuosNotifier,
  });

  // Criar um resíduo
  Future<void> createResiduo(Map<String, dynamic> residuoData) async {
    messageNotifier.value = 'Criando resíduo...';

    final result = await residuoService.createResiduo(residuoData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Resíduo criado com sucesso';
    }
  }

  // Listar todos os resíduos
  Future<void> loadResiduosNaoEnviados() async {
    messageNotifier.value = 'Carregando resíduos não enviados...';

    final result = await residuoService.getResiduosNaoEnviados();

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      residuosNotifier.value = result['residuos'];
      messageNotifier.value = 'Resíduos carregados com sucesso';
    }
  }

  // Listar resíduos enviados
  Future<void> loadAllResiduos() async {
    messageNotifier.value = 'Carregando resíduos enviados...';

    final result = await residuoService.getAllResiduos();

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      residuosNotifier.value = result['residuos'];
      messageNotifier.value = 'Resíduos carregados com sucesso';
    }
  }

  // Atualizar um resíduo
  Future<void> updateResiduo(String id, Map<String, dynamic> updatedData) async {
    messageNotifier.value = 'Atualizando resíduo...';

    final result = await residuoService.updateResiduo(id, updatedData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Resíduo atualizado com sucesso';
    }
  }

  // Excluir um resíduo
  Future<void> deleteResiduo(String id) async {
    messageNotifier.value = 'Excluindo resíduo...';

    final result = await residuoService.deleteResiduo(id);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Resíduo excluído com sucesso';
      loadResiduosNaoEnviados(); // Recarregar após exclusão
    }
  }
}
