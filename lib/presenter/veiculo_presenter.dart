import 'package:flutter/material.dart';
import '../services/veiculo_service.dart';

class VeiculoPresenter {
  final VeiculoService veiculoService;
  final ValueNotifier<String> messageNotifier;
  final ValueNotifier<List<dynamic>> veiculoNotifier;

  VeiculoPresenter({
    required this.veiculoService,
    required this.messageNotifier,
    required this.veiculoNotifier,
  });

  // Criar um Veículo
  Future<void> createVeiculo(Map<String, dynamic> veiculoData) async {
    messageNotifier.value = 'Criando veículo...';

    final result = await veiculoService.createVeiculo(veiculoData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Veículo criado com sucesso';
    }
  }

  // Listar Veículos enviados
  Future<void> loadAllVeiculos() async {
    messageNotifier.value = 'Carregando veículos enviados...';

    final result = await veiculoService.getAllVeiculo();

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      veiculoNotifier.value = result['veiculos'];
      messageNotifier.value = 'Veículos carregados com sucesso';
    }
  }

  // Atualizar um Veículo
  Future<void> updateVeiculo(String id, Map<String, dynamic> updatedData) async {
    messageNotifier.value = 'Atualizando Veículo...';

    final result = await veiculoService.updateVeiculo(id, updatedData);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Veículo atualizado com sucesso';
    }
  }

  // Excluir um Veículo
  Future<void> deleteVeiculo(String id) async {
    messageNotifier.value = 'Excluindo Veículo...';

    final result = await veiculoService.deleteVeiculo(id);

    if (result.containsKey('error')) {
      messageNotifier.value = result['error'];
    } else {
      messageNotifier.value = 'Veículo excluído com sucesso';
      loadAllVeiculos(); // Recarregar após exclusão
    }
  }
}
