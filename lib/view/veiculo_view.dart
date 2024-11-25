// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'veiculo_form.dart';
import 'app_bar.dart';
import '../services/veiculo_service.dart';
import '../presenter/veiculo_presenter.dart';

class VeiculoView extends StatefulWidget {
  const VeiculoView({super.key});

  @override
  _VeiculoViewState createState() => _VeiculoViewState();
}

class _VeiculoViewState extends State<VeiculoView> {
  final VeiculoService _veiculoService = VeiculoService();
  late VeiculoPresenter _presenter;
  List<dynamic> veiculo = [];

  @override
  void initState() {
    super.initState();

    // Inicializando o Presenter com os ValueNotifiers
    _presenter = VeiculoPresenter(
      veiculoService: _veiculoService,
      messageNotifier: ValueNotifier(''),
      veiculoNotifier: ValueNotifier(veiculo),
    );

    // Carregar apenas resíduos não enviados
    _presenter.loadAllVeiculos();
  }

  Future<void> _deleteVeiculo(String id) async {
    await _presenter.deleteVeiculo(id);
    _presenter.loadAllVeiculos();
  }

  Future<void> _editVeiculo(String id, dynamic veiculo) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VeiculoForm(veiculo: veiculo)),
    );

    if (atualizado != null) {
      _presenter.updateVeiculo(id, atualizado);
      _presenter.loadAllVeiculos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Veículos'),
      body: Container(
        color: const Color(0xFF22C55E), // Background verde
        child: Column(
          children: [
            // Exibir mensagens de status
            ValueListenableBuilder<String>(
              valueListenable: _presenter.messageNotifier,
              builder: (context, message, child) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
            Expanded(
              // Exibir tabela de veículos dentro de um container branco
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<List<dynamic>>(
                  valueListenable: _presenter.veiculoNotifier,
                  builder: (context, veiculos, child) {
                    if (veiculos.isEmpty) {
                      return const Center(
                        child: Text('Nenhum veículo encontrado.'),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis
                          .horizontal, // Scroll horizontal para caber todas as colunas
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Placa')),
                          DataColumn(label: Text('Modelo')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: veiculos.map((veiculo) {
                          return DataRow(cells: [
                            DataCell(Text(veiculo['placa'])),
                            DataCell(Text(veiculo['modelo'])),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editVeiculo(veiculo['id'], veiculo);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteVeiculo(veiculo['id']);
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final novoVeiculo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VeiculoForm()),
          );

          if (novoVeiculo != null) {
            _presenter.createVeiculo(novoVeiculo);
            _presenter.loadAllVeiculos();
          }
        },
        backgroundColor: const Color(0xFF22C55E),
        child: const Icon(Icons.add),
      ),
    );
  }
}
