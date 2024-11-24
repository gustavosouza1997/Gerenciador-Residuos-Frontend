// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class VeiculoForm extends StatefulWidget {
  const VeiculoForm({super.key});

  @override
  State<VeiculoForm> createState() => _VeiculoFormState();

}

class _VeiculoFormState extends State<VeiculoForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();

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
      appBar: AppBar(title: const Text('Dados FEPAM')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira a placa do veículo' : null,
              ),
              TextFormField(
                controller: _marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira a marca do veículo' : null,
              ),
              TextFormField(
                controller: _modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira o modelo do veículo' : null,
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
    );
  }
}
