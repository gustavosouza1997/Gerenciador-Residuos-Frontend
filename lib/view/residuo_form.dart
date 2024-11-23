// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/mtr_service.dart';

class ResiduoForm extends StatefulWidget {
  const ResiduoForm({super.key});

  @override
  State<ResiduoForm> createState() => _ResiduoFormState();
}

class _ResiduoFormState extends State<ResiduoForm> {
  final MTRService _mtrService = MTRService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeResiduoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _codigoAcondicionamentoController = TextEditingController();
  final TextEditingController _codigoClasseController = TextEditingController();
  final TextEditingController _codigoEstadoFisicoController = TextEditingController();
  final TextEditingController _codigoResiduoController = TextEditingController();
  final TextEditingController _codigoTecnologiaController = TextEditingController();
  final TextEditingController _codigoUnidadeController = TextEditingController();
  
  String? _selectedAcondicionamento;
  String? _selectedClasse;
  String? _selectedEstadoFisico;
  String? _selectedResiduo;
  String? _selectedTecnologia;
  String? _selectedUnidade;

  List<Map<String, dynamic>> acondicionamentoOptions = [];
  List<Map<String, dynamic>> classeOptions = [];
  List<Map<String, dynamic>> estadoFisicoOptions = [];
  List<Map<String, dynamic>> residuoOptions = [];
  List<Map<String, dynamic>> tecnologiaOptions = [];
  List<Map<String, dynamic>> unidadeOptions = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
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
        SnackBar(content: Text('Erro ao carregar opções: $e')) ,
      );
    }
  }

  void _saveResiduo() {
    if (_formKey.currentState!.validate()) {
      final residuo = {
        "nomeResiduo": _nomeResiduoController.text,
        "quantidade": double.tryParse(_quantidadeController.text) ?? 0,
        "codigoAcondicionamento": _selectedAcondicionamento,
        "codigoClasse": _selectedClasse,
        "codigoTecnologia": _selectedTecnologia,
        "codigoTipoEstado": _selectedEstadoFisico,
        "codigoUnidade": _selectedUnidade,
        "manifestoItemObservacao": _observacaoController.text,
        "dataCriacao": DateTime.now().toIso8601String(),
      };

      Navigator.pop(context, residuo);
    }
  }


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Resíduo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeResiduoController,
                decoration: const InputDecoration(labelText: 'Nome do Resíduo'),
                validator: (value) =>
                    value!.isEmpty ? 'Este campo é obrigatório' : null,
              ),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(labelText: 'Quantidade'),
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
                  .where((option) => option['descricao'].toString().contains(search)).toList(),
                controller: _codigoResiduoController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Código Resíduo',
                    )
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text('${value['codigo']} - ${value['descricao']} '),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    _selectedResiduo = selection['codigo'];
                    _codigoResiduoController.text = '${selection['codigo']} - ${selection['descricao']} ';
                  });
                },
              ),

              TypeAheadField<Map<String, dynamic>>(
                suggestionsCallback: (search) => unidadeOptions
                  .where((option) => option['descricao'].toString().contains(search)).toList(),
                controller: _codigoUnidadeController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Código Unidade',
                    )
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text(value['descricao']),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    _selectedUnidade = selection['codigo'];
                    _codigoUnidadeController.text = selection['descricao'];
                  });
                },
              ),

              TypeAheadField<Map<String, dynamic>>(
                suggestionsCallback: (search) => estadoFisicoOptions
                  .where((option) => option['descricao'].toString().contains(search)).toList(),
                controller: _codigoEstadoFisicoController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Código Estado Físico',
                    )
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text(value['descricao']),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    _selectedEstadoFisico = selection['codigo'];
                    _codigoEstadoFisicoController.text = selection['descricao'];
                  });
                },
              ),

              TypeAheadField<Map<String, dynamic>>(
                suggestionsCallback: (search) => classeOptions
                  .where((option) => option['descricao'].toString().contains(search)).toList(),
                controller: _codigoClasseController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Código Classe',
                    )
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text(value['descricao']),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    _selectedClasse = selection['codigo'];
                    _codigoClasseController.text = selection['descricao'];
                  });
                },
              ),

              TypeAheadField<Map<String, dynamic>>(
                suggestionsCallback: (search) => acondicionamentoOptions
                  .where((option) => option['descricao'].toString().contains(search)).toList(),
                controller: _codigoAcondicionamentoController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Código Acondicionamento',
                    )
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text(value['descricao']),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    _selectedAcondicionamento = selection['codigo'];
                    _codigoAcondicionamentoController.text = selection['descricao'];
                  });
                },
              ),

              TypeAheadField<Map<String, dynamic>>(
                suggestionsCallback: (search) => tecnologiaOptions
                  .where((option) => option['descricao'].toString().contains(search)).toList(),
                controller: _codigoTecnologiaController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Código Tecnologia',
                    )
                  );
                },
                itemBuilder: (context, value) {
                  return ListTile(
                    title: Text(value['descricao']),
                  );
                },
                onSelected: (selection) {
                  setState(() {
                    _selectedTecnologia = selection['codigo'];
                    _codigoTecnologiaController.text = selection['descricao'];
                  });
                },
              ),

              TextFormField(
                 controller: _observacaoController,
                 decoration: const InputDecoration(labelText: 'Observação (opcional)'),
                 maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveResiduo,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}