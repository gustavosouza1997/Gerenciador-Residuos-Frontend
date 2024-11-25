// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'app_bar.dart';
import '../services/mtr_service.dart';

class ResiduoForm extends StatefulWidget {
  final Map<String, dynamic>? residuo;

  const ResiduoForm({super.key, this.residuo});

  @override
  State<ResiduoForm> createState() => _ResiduoFormState();
}

class _ResiduoFormState extends State<ResiduoForm> {
  final MTRService _mtrService = MTRService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeResiduoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _codigoAcondicionamentoController =
      TextEditingController();
  final TextEditingController _codigoClasseController = TextEditingController();
  final TextEditingController _codigoEstadoFisicoController =
      TextEditingController();
  final TextEditingController _codigoResiduoController =
      TextEditingController();
  final TextEditingController _codigoTecnologiaController =
      TextEditingController();
  final TextEditingController _codigoUnidadeController =
      TextEditingController();

  String? _selectedAcondicionamento;
  String? _selectedClasse;
  String? _selectedEstadoFisico;
  String? _selectedResiduo;
  String? _selectedTecnologia;
  String? _selectedUnidade;

  late bool _isLoading;

  List<Map<String, dynamic>> acondicionamentoOptions = [];
  List<Map<String, dynamic>> classeOptions = [];
  List<Map<String, dynamic>> estadoFisicoOptions = [];
  List<Map<String, dynamic>> residuoOptions = [];
  List<Map<String, dynamic>> tecnologiaOptions = [];
  List<Map<String, dynamic>> unidadeOptions = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadOptions();

      if (widget.residuo != null) {
        _loadResiduoData(widget.residuo!);
      } else {
        _resetFormFields();
      }
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

  void _resetFormFields() {
    _nomeResiduoController.clear();
    _quantidadeController.clear();
    _observacaoController.clear();
    _codigoAcondicionamentoController.clear();
    _codigoClasseController.clear();
    _codigoEstadoFisicoController.clear();
    _codigoResiduoController.clear();
    _codigoTecnologiaController.clear();
    _codigoUnidadeController.clear();

    _selectedAcondicionamento = null;
    _selectedClasse = null;
    _selectedEstadoFisico = null;
    _selectedResiduo = null;
    _selectedTecnologia = null;
    _selectedUnidade = null;
  }

  Future<void> _loadOptions() async {
    try {
      acondicionamentoOptions = (await _mtrService.fetchAcondicionamento())
          .map((item) => {
                'codigo': item['tipoCodigo'].toString(),
                'descricao': item['tipoDescricao'],
              })
          .toList();

      classeOptions = (await _mtrService.fetchClasse())
          .map((item) => {
                'codigo': item['tpclaCodigo'].toString(),
                'descricao': item['tpclaDescricao'],
              })
          .toList();

      estadoFisicoOptions = (await _mtrService.fetchEstadoFisico())
          .map((item) => {
                'codigo': item['tpestCodigo'].toString(),
                'descricao': item['tpestDescricao'],
              })
          .toList();

      tecnologiaOptions = (await _mtrService.fetchTecnologia())
          .map((item) => {
                'codigo': item['tipoCodigo'].toString(),
                'descricao': item['tipoDescricao'],
              })
          .toList();

      unidadeOptions = (await _mtrService.fetchUnidade())
          .map((item) => {
                'codigo': item['tpuniCodigo'].toString(),
                'descricao': item['tpuniDescricao'],
              })
          .toList();

      residuoOptions = (await _mtrService.fetchResiduo())
          .map((item) => {
                'codigo': item['tpre3Numero'],
                'descricao': item['tpre3Descricao'],
              })
          .toList();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar opções: $e')),
      );
    }
  }

  void _loadResiduoData(Map<String, dynamic> residuo) {
    _nomeResiduoController.text = residuo['nomeResiduo'] ?? '';
    _quantidadeController.text = residuo['quantidade']?.toString() ?? '';
    _observacaoController.text = residuo['manifestoItemObservacao'] ?? '';
    _selectedAcondicionamento = residuo['codigoAcondicionamento'];
    _selectedClasse = residuo['codigoClasse'];
    _selectedEstadoFisico = residuo['codigoTipoEstado'];
    _selectedResiduo = residuo['codigoResiduo'];
    _selectedTecnologia = residuo['codigoTecnologia'];
    _selectedUnidade = residuo['codigoUnidade'];

    final acondicionamentoDescricao = acondicionamentoOptions.firstWhere(
        (element) => element['codigo'] == residuo['codigoAcondicionamento']);
    _codigoAcondicionamentoController.text =
        acondicionamentoDescricao['descricao'];

    final classeDescricao = classeOptions
        .firstWhere((element) => element['codigo'] == residuo['codigoClasse']);
    _codigoClasseController.text = classeDescricao['descricao'];

    final estadoFisicoDescricao = estadoFisicoOptions.firstWhere(
        (element) => element['codigo'] == residuo['codigoTipoEstado']);
    _codigoEstadoFisicoController.text = estadoFisicoDescricao['descricao'];

    final residuoDescricao = residuoOptions
        .firstWhere((element) => element['codigo'] == residuo['codigoResiduo']);
    _codigoResiduoController.text = residuoDescricao['descricao'];

    final tecnologiaDescricao = tecnologiaOptions.firstWhere(
        (element) => element['codigo'] == residuo['codigoTecnologia']);
    _codigoTecnologiaController.text = tecnologiaDescricao['descricao'];

    final unidadeDescricao = unidadeOptions
        .firstWhere((element) => element['codigo'] == residuo['codigoUnidade']);
    _codigoUnidadeController.text = unidadeDescricao['descricao'];
  }

  void _saveResiduo() {
    if (_formKey.currentState!.validate()) {
      String errorMessage = '';

      if (_selectedResiduo == null) {
        errorMessage += 'Selecione um resíduo.\n';
      }
      if (_selectedUnidade == null) {
        errorMessage += 'Selecione uma unidade.\n';
      }
      if (_selectedEstadoFisico == null) {
        errorMessage += 'Selecione um estado físico.\n';
      }
      if (_selectedClasse == null) {
        errorMessage += 'Selecione uma classe.\n';
      }
      if (_selectedAcondicionamento == null) {
        errorMessage += 'Selecione um acondicionamento.\n';
      }
      if (_selectedTecnologia == null) {
        errorMessage += 'Selecione uma tecnologia.\n';
      }

      final residuo = {
        "nomeResiduo": _nomeResiduoController.text,
        "quantidade": double.tryParse(_quantidadeController.text) ?? 0,
        "codigoAcondicionamento": _selectedAcondicionamento,
        "codigoClasse": _selectedClasse,
        "codigoTecnologia": _selectedTecnologia,
        "codigoTipoEstado": _selectedEstadoFisico,
        "codigoResiduo": _selectedResiduo,
        "codigoUnidade": _selectedUnidade,
        "manifestoItemObservacao": _observacaoController.text,
        "dataCriacao": DateTime.now().toIso8601String(),
      };

      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        Navigator.pop(context, residuo);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(titulo: 'Cadastrar Resíduos'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: const Color(0xFF22C55E),
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nomeResiduoController,
                              decoration: const InputDecoration(
                                  labelText: 'Nome do Resíduo'),
                              validator: (value) => value!.isEmpty
                                  ? 'Este campo é obrigatório'
                                  : null,
                            ),
                            TextFormField(
                              controller: _quantidadeController,
                              decoration: const InputDecoration(
                                  labelText: 'Quantidade'),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Este campo é obrigatório';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Por favor, insira um número válido';
                                }
                                return null;
                              },
                            ),
                            TypeAheadField<Map<String, dynamic>>(
                              suggestionsCallback: (search) => residuoOptions
                                  .where((option) => option['descricao']
                                      .toString()
                                      .contains(search))
                                  .toList(),
                              controller: _codigoResiduoController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Código Resíduo'));
                              },
                              itemBuilder: (context, value) {
                                return ListTile(
                                  title: Text(
                                      '${value['codigo']} - ${value['descricao']} '),
                                );
                              },
                              onSelected: (selection) {
                                setState(() {
                                  _selectedResiduo = selection['codigo'];
                                  _codigoResiduoController.text =
                                      '${selection['codigo']} - ${selection['descricao']}';
                                });
                              },
                            ),
                            TypeAheadField<Map<String, dynamic>>(
                              suggestionsCallback: (search) => unidadeOptions
                                  .where((option) => option['descricao']
                                      .toString()
                                      .contains(search))
                                  .toList(),
                              controller: _codigoUnidadeController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Código Unidade'));
                              },
                              itemBuilder: (context, value) {
                                return ListTile(
                                  title: Text(value['descricao']),
                                );
                              },
                              onSelected: (selection) {
                                setState(() {
                                  _selectedUnidade = selection['codigo'];
                                  _codigoUnidadeController.text =
                                      selection['descricao'];
                                });
                              },
                            ),
                            TypeAheadField<Map<String, dynamic>>(
                              suggestionsCallback: (search) =>
                                  estadoFisicoOptions
                                      .where((option) => option['descricao']
                                          .toString()
                                          .contains(search))
                                      .toList(),
                              controller: _codigoEstadoFisicoController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Código Estado Físico'));
                              },
                              itemBuilder: (context, value) {
                                return ListTile(
                                  title: Text(value['descricao']),
                                );
                              },
                              onSelected: (selection) {
                                setState(() {
                                  _selectedEstadoFisico = selection['codigo'];
                                  _codigoEstadoFisicoController.text =
                                      selection['descricao'];
                                });
                              },
                            ),
                            TypeAheadField<Map<String, dynamic>>(
                              suggestionsCallback: (search) => classeOptions
                                  .where((option) => option['descricao']
                                      .toString()
                                      .contains(search))
                                  .toList(),
                              controller: _codigoClasseController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Código Classe'));
                              },
                              itemBuilder: (context, value) {
                                return ListTile(
                                  title: Text(value['descricao']),
                                );
                              },
                              onSelected: (selection) {
                                setState(() {
                                  _selectedClasse = selection['codigo'];
                                  _codigoClasseController.text =
                                      selection['descricao'];
                                });
                              },
                            ),
                            TypeAheadField<Map<String, dynamic>>(
                              suggestionsCallback: (search) =>
                                  acondicionamentoOptions
                                      .where((option) => option['descricao']
                                          .toString()
                                          .contains(search))
                                      .toList(),
                              controller: _codigoAcondicionamentoController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Código Acondicionamento'));
                              },
                              itemBuilder: (context, value) {
                                return ListTile(
                                  title: Text(value['descricao']),
                                );
                              },
                              onSelected: (selection) {
                                setState(() {
                                  _selectedAcondicionamento =
                                      selection['codigo'];
                                  _codigoAcondicionamentoController.text =
                                      selection['descricao'];
                                });
                              },
                            ),
                            TypeAheadField<Map<String, dynamic>>(
                              suggestionsCallback: (search) => tecnologiaOptions
                                  .where((option) => option['descricao']
                                      .toString()
                                      .contains(search))
                                  .toList(),
                              controller: _codigoTecnologiaController,
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: const InputDecoration(
                                        labelText: 'Código Tecnologia'));
                              },
                              itemBuilder: (context, value) {
                                return ListTile(
                                  title: Text(value['descricao']),
                                );
                              },
                              onSelected: (selection) {
                                setState(() {
                                  _selectedTecnologia = selection['codigo'];
                                  _codigoTecnologiaController.text =
                                      selection['descricao'];
                                });
                              },
                            ),
                            TextFormField(
                              controller: _observacaoController,
                              decoration: const InputDecoration(
                                  labelText: 'Observação (opcional)'),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _saveResiduo,
                              child: const Text('Salvar'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
