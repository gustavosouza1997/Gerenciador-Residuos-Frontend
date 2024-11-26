// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'pessoa_form.dart';
import 'app_bar.dart';
import '../services/pessoa_service.dart';
import '../presenter/pessoa_presenter.dart';

class PessoaView extends StatefulWidget {
  const PessoaView({super.key});

  @override
  _PessoaViewState createState() => _PessoaViewState();
}

class _PessoaViewState extends State<PessoaView> {
  final PessoaService _pessoaService = PessoaService();
  late PessoaPresenter _presenter;
  List<dynamic> pessoa = [];

  @override
  void initState() {
    super.initState();

    // Inicializando o Presenter com os ValueNotifiers
    _presenter = PessoaPresenter(
      pessoaService: _pessoaService,
      messageNotifier: ValueNotifier(''),
      pessoasNotifier: ValueNotifier(pessoa),
    );

    _presenter.loadAllPessoas();
  }

  Future<void> _deletePessoa(String id) async {
    await _presenter.deletePessoa(id);
    _presenter.loadAllPessoas();
  }

  void _editPessoa(String id, dynamic pessoa) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PessoaForm(pessoa: pessoa)),
    );

    if (atualizado != null) {
      _presenter.updatePessoa(id, atualizado);
      _presenter.loadAllPessoas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titulo: 'Pessoas'),
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
              // Exibir tabela de pessoas dentro de um container branco
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
                  valueListenable: _presenter.pessoasNotifier,
                  builder: (context, pessoas, child) {
                    if (pessoas.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma pessoa encontrada.'),
                      );
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis
                          .horizontal, // Scroll horizontal para caber todas as colunas
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                        ),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Nome')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: pessoas.map((pessoa) {
                            return DataRow(cells: [
                              DataCell(Text(pessoa['nome'] ??
                                  pessoa['razaoSocial'] ??
                                  '')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      _editPessoa(pessoa['id'], pessoa);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _deletePessoa(pessoa['id']);
                                    },
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
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
          final novoPessoa = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PessoaForm()),
          );

          if (novoPessoa != null) {
            _presenter.createPessoa(novoPessoa);
            _presenter.loadAllPessoas();
          }
        },
        backgroundColor: const Color(0xFF22C55E),
        child: const Icon(Icons.add),
      ),
    );
  }
}
