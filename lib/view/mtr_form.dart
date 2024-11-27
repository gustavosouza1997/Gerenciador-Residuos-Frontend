// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import './app_bar.dart';
import '../presenter/pessoa_presenter.dart';
import '../presenter/residuo_presenter.dart';
import '../presenter/veiculo_presenter.dart';
import '../services/pessoa_service.dart';
import '../services/residuo_service.dart';
import '../services/veiculo_service.dart';
import '../presenter/mtr_presenter.dart';

class MtrForm extends StatefulWidget {
  const MtrForm({super.key});

  @override
  State<MtrForm> createState() => _MtrFormState();
}

class _MtrFormState extends State<MtrForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeEmpresaGeradora = TextEditingController();
  final TextEditingController _manifGeradorNomeResponsavel =
      TextEditingController();
  final TextEditingController _manifGeradorCargoResponsavel =
      TextEditingController();
  final TextEditingController _nomeEmpresaTransportador =
      TextEditingController();
  final TextEditingController _manifTransportadorNomeMotorista =
      TextEditingController();
  final TextEditingController _manifTransportadorPlacaVeiculo =
      TextEditingController();
  final TextEditingController _nomeEmpresaDestinador = TextEditingController();

  final PessoaService _pessoaService = PessoaService();
  final ResiduoService _residuoService = ResiduoService();
  final VeiculoService _veiculoService = VeiculoService();

  final MTRPresenter _mtrPresenter = MTRPresenter();
  late final PessoaPresenter _pessoaPresenter;
  late final ResiduoPresenter _residuoPresenter;
  late final VeiculoPresenter _veiculoPresenter;

  late bool _isLoading;

  List<Map<String, dynamic>> _pessoaOptions = [];
  List<Map<String, dynamic>> _veiculoOptions = [];
  List<Map<String, dynamic>> _residuoOptions = [];

  final Set<Map<String, dynamic>> _selecionados = <Map<String, dynamic>>{};

  @override
  void initState() {
    super.initState();
    _pessoaPresenter = PessoaPresenter(
      pessoaService: _pessoaService,
      messageNotifier: ValueNotifier(''),
      pessoasNotifier: ValueNotifier([]),
    );
    _residuoPresenter = ResiduoPresenter(
      residuoService: _residuoService,
      messageNotifier: ValueNotifier(''),
      residuosNotifier: ValueNotifier([]),
    );
    _veiculoPresenter = VeiculoPresenter(
      veiculoService: _veiculoService,
      messageNotifier: ValueNotifier(''),
      veiculoNotifier: ValueNotifier([]),
    );

    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //final options = await _mtrPresenter.fetchOptions();
      final pessoasOptions = await _pessoaPresenter.getAllPessoas();
      final veiculosOptions = await _veiculoPresenter.getAllVeiculos();
      final residuosOptions = await _residuoPresenter.getAllResiduos();

      setState(() {
        _pessoaOptions = pessoasOptions['pessoas'] ?? [];
        _veiculoOptions = veiculosOptions['veiculos'] ?? [];
        _residuoOptions = residuosOptions['residuos'] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar opções: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _enviarMTR() async {
    if (_formKey.currentState!.validate()) {
      try {
        final manifestoDto = {
          'manifestoJSONDtos': [
            {
              'cnpTransportador': _pessoaOptions
                  .firstWhere((p) => p['nome'] == _nomeEmpresaTransportador.text)['cnpj'],
              'codUnidadeTransportador': '24552',
              'cnpDestinador': _pessoaOptions
                  .firstWhere((p) => p['nome'] == _nomeEmpresaDestinador.text)['cnpj'],
              'codUnidadeDestinador': '24552',
              'manifTransportadorDataExpedicao': 
                  DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 8),
              'manifTransportadorNomeMotorista': _manifTransportadorNomeMotorista.text,
              'manifTransportadorPlacaVeiculo': _manifTransportadorPlacaVeiculo.text,
              'manifGeradorNomeResponsavel': _manifGeradorNomeResponsavel.text,
              'manifGeradorCargoResponsavel': _manifGeradorCargoResponsavel.text,
              'itemManifestoJSONs': _selecionados.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final residuo = entry.value;
                
                return {
                  'codigoSequencial': (index + 1),
                  'residuo': residuo['codigoResiduo'],
                  'quantidade': num.tryParse(residuo['quantidade'].toString()) ?? 0,
                  'codigoUnidade': num.tryParse(residuo['codigoUnidade'].toString()) ?? 1,
                  'codigoTipoEstado': num.tryParse(residuo['codigoTipoEstado'].toString()) ?? 1,
                  'codigoClasse': num.tryParse(residuo['codigoClasse'].toString()) ?? 1,
                  'codigoAcondicionamento': num.tryParse(residuo['codigoAcondicionamento'].toString()) ?? 1,
                  'codigoTecnologia': num.tryParse(residuo['codigoTecnologia'].toString()) ?? 1,
                  'manifestoItemObservacao': residuo['manifestoItemObservacao'] ?? '',
                };
              }).toList(),
            }
          ]
        };

        final result = await _mtrPresenter.salvarManifesto(manifestoDto);
        
        String mensagem = 'MTR enviado com sucesso!';
        if (result.isNotEmpty && result[0].containsKey('manifestoCodigo')) {
          mensagem += ' Código: ${result[0]['manifestoCodigo']}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar MTR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22C55E),
      appBar: const CustomAppBar(titulo: 'Emitir MTR'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logo_fepam.png',
                          width: 100,
                          height: 100,
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ValueListenableBuilder<List<dynamic>>(
                                  valueListenable:
                                      _residuoPresenter.residuosNotifier,
                                  builder: (context, residuos, child) {
                                    final List<dynamic> residuoOption =
                                        _residuoOptions;

                                    if (residuoOption.isEmpty) {
                                      return const Center(
                                        child: Text(
                                            'Nenhum resíduo não enviado encontrado.'),
                                      );
                                    }
                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 35,
                                        columns: const [
                                          DataColumn(label: SizedBox(width: 24)),
                                          DataColumn(label: Text('Resíduo')),
                                          DataColumn(label: Text('Quant.')),
                                        ],
                                        rows: residuoOption.map((residuo) {
                                          final bool isSelecionado = _selecionados
                                              .any((r) => r['id'] == residuo['id']);

                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Checkbox(
                                                  value: isSelecionado,
                                                  onChanged: (bool? checked) {
                                                    setState(() {
                                                      if (checked == true) {
                                                        _selecionados.add(residuo);
                                                      } else {
                                                        _selecionados.removeWhere(
                                                          (r) => r['id'] == residuo['id']
                                                        );
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 60,
                                                  child: Text(
                                                    residuo['nomeResiduo'] ??
                                                        '',
                                                        overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text(
                                                  residuo['quantidade']
                                                          ?.toString() ??
                                                      '0')),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 20.0, horizontal: 16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Identificação do Gerador\n',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TypeAheadField<Map<String, dynamic>>(
                                      suggestionsCallback: (search) =>
                                          _pessoaOptions
                                              .where((option) =>
                                                  option.containsKey('cnpj') &&
                                                  option['cnpj'] != null &&
                                                  option['cnpj']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  option['gerador'] == true &&
                                                  option['nome']
                                                      .toString()
                                                      .contains(search))
                                              .toList(),
                                      controller: _nomeEmpresaGeradora,
                                      builder:
                                          (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Empresa Geradora dos Resíduos',
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, value) {
                                        return ListTile(
                                          title: Text('${value['nome']} '),
                                        );
                                      },
                                      onSelected: (selection) {
                                        setState(() {
                                          _nomeEmpresaGeradora.text =
                                              selection['nome'];
                                        });
                                      },
                                    ),
                                    TypeAheadField<Map<String, dynamic>>(
                                      suggestionsCallback: (search) =>
                                          _pessoaOptions
                                              .where((option) =>
                                                  option.containsKey('cpf') &&
                                                  option['cpf'] != null &&
                                                  option['cpf']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  option['nome']
                                                      .toString()
                                                      .contains(search))
                                              .toList(),
                                      controller: _manifGeradorNomeResponsavel,
                                      builder:
                                          (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Responsável pela Emissão',
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, value) {
                                        return ListTile(
                                          title: Text('${value['nome']} '),
                                        );
                                      },
                                      onSelected: (selection) {
                                        setState(() {
                                          _manifGeradorNomeResponsavel.text =
                                              selection['nome'];
                                        });
                                      },
                                    ),
                                    TextField(
                                      controller: _manifGeradorCargoResponsavel,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Cargo do Responsável pela Emissão',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Identificação do Transportador\n',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TypeAheadField<Map<String, dynamic>>(
                                      suggestionsCallback: (search) =>
                                          _pessoaOptions
                                              .where((option) =>
                                                  option.containsKey('cnpj') &&
                                                  option['cnpj'] != null &&
                                                  option['cnpj']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  option['transportador'] ==
                                                      true &&
                                                  option['nome']
                                                      .toString()
                                                      .contains(search))
                                              .toList(),
                                      controller: _nomeEmpresaTransportador,
                                      builder:
                                          (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Empresa Transportadora dos Resíduos',
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, value) {
                                        return ListTile(
                                          title: Text('${value['nome']} '),
                                        );
                                      },
                                      onSelected: (selection) {
                                        setState(() {
                                          _nomeEmpresaTransportador.text =
                                              selection['nome'];
                                        });
                                      },
                                    ),
                                    TypeAheadField<Map<String, dynamic>>(
                                      suggestionsCallback: (search) =>
                                          _pessoaOptions
                                              .where((option) =>
                                                  option.containsKey('cpf') &&
                                                  option['cpf'] != null &&
                                                  option['cpf']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  option['motorista'] == true &&
                                                  option['nome']
                                                      .toString()
                                                      .contains(search))
                                              .toList(),
                                      controller:
                                          _manifTransportadorNomeMotorista,
                                      builder:
                                          (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText: 'Motorista',
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, value) {
                                        return ListTile(
                                          title: Text('${value['nome']} '),
                                        );
                                      },
                                      onSelected: (selection) {
                                        setState(() {
                                          _manifTransportadorNomeMotorista
                                              .text = selection['nome'];
                                        });
                                      },
                                    ),
                                    TypeAheadField<Map<String, dynamic>>(
                                      suggestionsCallback: (search) =>
                                          _veiculoOptions
                                              .where((option) => option['placa']
                                                  .toString()
                                                  .contains(search))
                                              .toList(),
                                      controller:
                                          _manifTransportadorPlacaVeiculo,
                                      builder:
                                          (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText: 'Veículo',
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, value) {
                                        return ListTile(
                                          title: Text('${value['placa']} '),
                                          subtitle: Text('${value['modelo']} '),
                                        );
                                      },
                                      onSelected: (selection) {
                                        setState(() {
                                          _manifTransportadorPlacaVeiculo.text =
                                              selection['placa'];
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Identificação do Destinador\n',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TypeAheadField<Map<String, dynamic>>(
                                      suggestionsCallback: (search) =>
                                          _pessoaOptions
                                              .where((option) =>
                                                  option.containsKey('cnpj') &&
                                                  option['cnpj'] != null &&
                                                  option['cnpj']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  option['destinador'] ==
                                                      true &&
                                                  option['nome']
                                                      .toString()
                                                      .contains(search))
                                              .toList(),
                                      controller: _nomeEmpresaDestinador,
                                      builder:
                                          (context, controller, focusNode) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Empresa Destinadora dos Resíduos',
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, value) {
                                        return ListTile(
                                          title: Text('${value['nome']} '),
                                        );
                                      },
                                      onSelected: (selection) {
                                        setState(() {
                                          _nomeEmpresaDestinador.text =
                                              selection['nome'];
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _enviarMTR,
                          child: const Text('Enviar MTR'),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            )),
    );
  }
}
