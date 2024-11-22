// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gerenciador_residuos_frontend/services/mtr_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; 

class ResiduoForm extends StatefulWidget {
  const ResiduoForm({super.key});

  @override
  State<ResiduoForm> createState() => _ResiduoFormState();
}

class _ResiduoFormState extends State<ResiduoForm> {
  //final ResiduoService _residuoService = ResiduoService();
  final MTRService _mtrService = MTRService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeResiduoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();

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
      acondicionamentoOptions = (await _mtrService.fetchAcondicionamento()).map((item) => {
        'codigo': item['tipoCodigo'].toString(),
        'descricao': item['tipoDescricao'],
      }).toList();

      classeOptions = (await _mtrService.fetchClasse()).map((item) => {
        'codigo': item['tpclaCodigo'].toString(),
        'descricao': item['tpclaDescricao'],
      }).toList();

      estadoFisicoOptions = (await _mtrService.fetchEstadoFisico()).map((item) => {
      'codigo': item['tpestCodigo'].toString(),
      'descricao': item['tpestDescricao'],
    }).toList();

    tecnologiaOptions = (await _mtrService.fetchTecnologia()).map((item) => {
      'codigo': item['tipoCodigo'].toString(),
      'descricao': item['tipoDescricao'],
    }).toList();

    unidadeOptions = (await _mtrService.fetchUnidade()).map((item) => {
      'codigo': item['tpuniCodigo'].toString(),
      'descricao': item['tpuniDescricao'],
    }).toList();

      residuoOptions = (await _mtrService.fetchResiduo()).map((item) => {
        'codigo': item['tpre3Numero'],
        'descricao': item['tpre3Descricao'],
      }).toList();

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar opções: $e')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Permite o scroll no formulário
            child: Column( // Usar Column dentro do SingleChildScrollView
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
                _buildTypeAheadDropdown(
                  'Código Acondicionamento',
                  acondicionamentoOptions,
                  _selectedAcondicionamento,
                  (value) => setState(() => _selectedAcondicionamento = value),
                ),
                _buildTypeAheadDropdown(
                  'Código Classe',
                  classeOptions,
                  _selectedClasse,
                  (value) => setState(() => _selectedClasse = value),
                ),
                _buildTypeAheadDropdown(
                  'Código Estado Físico',
                  estadoFisicoOptions,
                  _selectedEstadoFisico,
                  (value) => setState(() => _selectedEstadoFisico = value),
                ),
                _buildTypeAheadDropdown(
                  'Código Resíduo',
                  residuoOptions,
                  _selectedResiduo,
                  (value) => setState(() => _selectedResiduo = value),
                ),
                _buildTypeAheadDropdown(
                  'Código Tecnologia',
                  tecnologiaOptions,
                  _selectedTecnologia,
                  (value) => setState(() => _selectedTecnologia = value),
                ),
                _buildTypeAheadDropdown(
                  'Código Unidade',
                  unidadeOptions,
                  _selectedUnidade,
                  (value) => setState(() => _selectedUnidade = value),
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
      ),
    );
  }

  Widget _buildTypeAheadDropdown(
    String label,
    List<Map<String, dynamic>> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: TextEditingController(text: selectedValue),
        decoration: InputDecoration(labelText: label),
      ),
      suggestionsCallback: (pattern) {
        return options
            .where((option) => option['descricao']
                .toLowerCase()
                .contains(pattern.toLowerCase()))
            .map<String>((option) => option['descricao'].toString());
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        onChanged(suggestion);
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Por favor, selecione uma opção' : null,
    );
  }
}
