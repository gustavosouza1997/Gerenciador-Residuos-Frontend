import 'package:flutter/material.dart';
import '../services/residuo_service.dart';
import '../presenter/residuo_presenter.dart';

class ResiduoForm extends StatefulWidget {
  const ResiduoForm({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResiduoFormState createState() => _ResiduoFormState();
}

class _ResiduoFormState extends State<ResiduoForm> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();

  final ResiduoService _residuoService = ResiduoService();
  late ResiduoPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = ResiduoPresenter(
      residuoService: _residuoService,
      messageNotifier: ValueNotifier(''),
      residuosNotifier: ValueNotifier([]),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> salvarResiduo() async {
    // Verificar se os campos não estão vazios
    if (_nomeController.text.isEmpty || _quantidadeController.text.isEmpty) {
      _presenter.messageNotifier.value = 'Por favor, preencha todos os campos.';
      return;
    }

    final residuoData = {
      'nomeResiduo': _nomeController.text,
      'quantidade': int.parse(_quantidadeController.text),
    };

    await _presenter.createResiduo(residuoData);

    // Retornar para a tela principal após salvar
    if (_presenter.messageNotifier.value == 'Resíduo criado com sucesso') {
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Voltar para a tela anterior (MainView)
    }
  }

  void cancelarCadastro() {
    Navigator.pop(context); // Voltar para a tela principal sem salvar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Resíduo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo para nome do resíduo
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Resíduo'),
            ),
            const SizedBox(height: 16),
            
            // Campo para quantidade
            TextField(
              controller: _quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Exibição de mensagens (ex: erro ou sucesso)
            ValueListenableBuilder<String>(
              valueListenable: _presenter.messageNotifier,
              builder: (context, message, child) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: message.contains('sucesso') ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão para cancelar
                ElevatedButton(
                  onPressed: cancelarCadastro,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Cancelar'),
                ),
                // Botão para salvar
                ElevatedButton(
                  onPressed: salvarResiduo,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
