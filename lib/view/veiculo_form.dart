// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import './app_bar.dart';

class VeiculoForm extends StatefulWidget {
  final Map<String, dynamic>? veiculo;

  const VeiculoForm({super.key, this.veiculo});

  @override
  State<VeiculoForm> createState() => _VeiculoFormState();
}

class _VeiculoFormState extends State<VeiculoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();

  late bool _isLoading;

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
      if (widget.veiculo != null) {
        _loadVeiculoData(widget.veiculo!);
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

  void _loadVeiculoData(Map<String, dynamic> veiculo) {
    _placaController.text = veiculo['placa'] ?? '';
    _marcaController.text = veiculo['marca'] ?? '';
    _modeloController.text = veiculo['modelo'] ?? '';
  }

  void _resetFormFields() {
    _placaController.clear();
    _marcaController.clear();
    _modeloController.clear();
  }

  void _saveVeiculo() {
    if (_formKey.currentState!.validate()) {
      final veiculo = {
        "placa": _placaController.text,
        "marca": _marcaController.text,
        "modelo": _modeloController.text,
      };

      Navigator.pop(context, veiculo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF22C55E),
      appBar: const CustomAppBar(titulo: 'Cadastrar Veículos'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
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
                      TextFormField(
                        controller: _placaController,
                        decoration: const InputDecoration(labelText: 'Placa'),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira a placa do veículo'
                            : null,
                      ),
                      TextFormField(
                        controller: _marcaController,
                        decoration: const InputDecoration(labelText: 'Marca'),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira a marca do veículo'
                            : null,
                      ),
                      TextFormField(
                        controller: _modeloController,
                        decoration: const InputDecoration(labelText: 'Modelo'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira o modelo do veículo'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _saveVeiculo,
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
