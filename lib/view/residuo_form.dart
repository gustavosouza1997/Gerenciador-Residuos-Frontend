// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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

  Widget _buildDropdown(
    String label,
    List<Map<String, dynamic>> options,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: selectedValue,
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option['codigo'],
                child: Text('${option['codigo']} - ${option['descricao']}'),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null ? 'Por favor, selecione uma opção' : null,
    );
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
              _buildDropdown(
                'Código Acondicionamento',
                acondicionamentoOptions,
                _selectedAcondicionamento,
                (value) => setState(() => _selectedAcondicionamento = value),
              ),
              _buildDropdown(
                'Código Classe',
                classeOptions,
                _selectedClasse,
                (value) => setState(() => _selectedClasse = value),
              ),
              _buildDropdown(
                'Código Estado Físico',
                estadoFisicoOptions,
                _selectedEstadoFisico,
                (value) => setState(() => _selectedEstadoFisico = value),
              ),
              _buildDropdown(
                'Código Resíduo',
                residuoOptions,
                _selectedResiduo,
                (value) => setState(() => _selectedResiduo = value),
              ),
              _buildDropdown(
                'Código Tecnologia',
                tecnologiaOptions,
                _selectedTecnologia,
                (value) => setState(() => _selectedTecnologia = value),
              ),
              _buildDropdown(
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
    );
  }
}
