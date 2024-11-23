import 'package:flutter/material.dart';
import 'residuo_form.dart';
import '../services/residuo_service.dart';
import '../presenter/residuo_presenter.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final ResiduoService _residuoService = ResiduoService();
  late ResiduoPresenter _presenter;
  List<dynamic> residuos = [];
  List<int> selectedResiduos = [];
  bool showSentResiduos = false; // Variável para alternar entre enviados e não enviados

  @override
  void initState() {
    super.initState();

    // Inicializando o Presenter com o ValueNotifier para resíduos e mensagens
    _presenter = ResiduoPresenter(
      residuoService: _residuoService,
      messageNotifier: ValueNotifier(''),
      residuosNotifier: ValueNotifier(residuos),
    );

    // Carregar resíduos não enviados por padrão
    _presenter.loadResiduosNaoEnviados();
  }

  Future<void> showDialog(Text e) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e')),
    );
  }

  Future<void> deleteResiduo(String id) async {
    await _presenter.deleteResiduo(id);
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedResiduos.contains(index)) {
        selectedResiduos.remove(index);
      } else {
        selectedResiduos.add(index);
      }
    });
  }

  // Alternar entre resíduos enviados e não enviados
  void toggleResiduosView(bool showSent) {
    setState(() {
      showSentResiduos = showSent;
    });
    if (showSentResiduos) {
      _presenter.loadAllResiduos(); // Carregar resíduos enviados
    } else {
      _presenter.loadResiduosNaoEnviados(); // Carregar resíduos não enviados
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resíduos')),
      body: Column(
        children: [
          // Botões para alternar entre enviados e não enviados
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => toggleResiduosView(false),
                child: const Text('Não Enviados'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => toggleResiduosView(true),
                child: const Text('Enviados'),
              ),
            ],
          ),
          // Exibindo mensagens de status
          ValueListenableBuilder<String>(
            valueListenable: _presenter.messageNotifier,
            builder: (context, message, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message),
              );
            },
          ),
          Expanded(
            // Exibindo a lista de resíduos
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: _presenter.residuosNotifier,
              builder: (context, residuos, child) {
                if (residuos.isEmpty) {
                  return Center(
                    child: showSentResiduos
                        ? const Text('Nenhum resíduo enviado encontrado.')
                        : const Text('Nenhum resíduo não enviado encontrado.'),
                  );
                }
                return ListView.builder(
                  itemCount: residuos.length,
                  itemBuilder: (context, index) {
                    final residuo = residuos[index];
                    final isSelected = selectedResiduos.contains(index);

                    return ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (_) => toggleSelection(index),
                      ),
                      title: Text(residuo['nomeResiduo']),
                      subtitle: Text('Quantidade: ${residuo['quantidade']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => {
                          deleteResiduo(residuo['id']),
                          _presenter.loadResiduosNaoEnviados()
                        },
                        

                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final novoResiduo = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ResiduoForm()),
          );

          if (novoResiduo != null) {
            setState(() {
              residuos.add(novoResiduo);
            });

            _presenter.createResiduo(novoResiduo);
            _presenter.loadResiduosNaoEnviados();
          }
        },
        
        child: const Icon(Icons.add),
      ),
    );
  }
}
