// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:gerenciador_residuos_front/view/app_bar.dart';
import 'residuo_form.dart';
import '../services/residuo_service.dart';
import '../presenter/residuo_presenter.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final ResiduoService _residuoService = ResiduoService();
  late ResiduoPresenter _presenter;
  List<dynamic> residuos = [];

  @override
  void initState() {
    super.initState();

    // Inicializando o Presenter com os ValueNotifiers
    _presenter = ResiduoPresenter(
      residuoService: _residuoService,
      messageNotifier: ValueNotifier(''),
      residuosNotifier: ValueNotifier(residuos),
    );

    // Carregar apenas resíduos não enviados
    _presenter.loadResiduosNaoEnviados();
  }

  Future<void> _deleteResiduo(String id) async {
    await _presenter.deleteResiduo(id);
    _presenter.loadResiduosNaoEnviados();
  }

  Future<void> _editResiduo(String id, dynamic residuo) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResiduoForm(residuo: residuo)),
    );

    if (atualizado != null) {
      _presenter.updateResiduo(id, atualizado);
      _presenter.loadResiduosNaoEnviados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Resíduos não enviados'),
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
              // Exibir tabela de resíduos dentro de um container branco
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
                  valueListenable: _presenter.residuosNotifier,
                  builder: (context, residuos, child) {
                    if (residuos.isEmpty) {
                      return const Center(
                        child: Text('Nenhum resíduo não enviado encontrado.'),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis
                          .horizontal, // Scroll horizontal para caber todas as colunas
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Nome')),
                          DataColumn(label: Text('Quantidade')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: residuos.map((residuo) {
                          return DataRow(cells: [
                            DataCell(Text(residuo['nomeResiduo'])),
                            DataCell(Text(residuo['quantidade'].toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editResiduo(residuo['id'], residuo);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteResiduo(residuo['id']);
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
          final novoResiduo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResiduoForm()),
          );

          if (novoResiduo != null) {
            _presenter.createResiduo(novoResiduo);
            _presenter.loadResiduosNaoEnviados(); // Atualizar lista após criar
          }
        },
        backgroundColor: const Color(0xFF22C55E),
        child: const Icon(Icons.add),
      ),
    );
  }
}
