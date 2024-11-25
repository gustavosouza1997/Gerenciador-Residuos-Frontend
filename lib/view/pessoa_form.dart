// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/ibge_service.dart';
import './app_bar.dart';

class PessoaForm extends StatefulWidget {
  final Map<String, dynamic>? pessoa;

  const PessoaForm({super.key, this.pessoa});

  @override
  State<PessoaForm> createState() => _PessoaFormState();
}

class _PessoaFormState extends State<PessoaForm> {
  final IBGEService _ibgeService = IBGEService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _nomeRazaoSocialController =
      TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _municipioController = TextEditingController();

  String? _uf;
  String? _municipio;
  bool? _isTransportador;
  bool? _isGerador;
  bool? _isDestinador;
  bool? _isMotorista;

  late bool _isLoading;

  List<Map<String, dynamic>> ufOptions = [];
  List<Map<String, dynamic>> municipioOptions = [];

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
      await _loadUFOptions();

      if (widget.pessoa != null) {
        _loadPessoaData(widget.pessoa!);
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

  void _loadPessoaData(Map<String, dynamic> pessoa) {
    if (pessoa['cpf'] != null) {
      _cpfCnpjController.text = pessoa['cpf'];
      _nomeRazaoSocialController.text = pessoa['nome'];
      _isMotorista = pessoa['motorista'];
    } else {
      _cpfCnpjController.text = pessoa['cnpj'];
      _nomeRazaoSocialController.text = pessoa['razaoSocial'];
    }

    _telefoneController.text = pessoa['telefone'];
    _emailController.text = pessoa['email'];
    _enderecoController.text = pessoa['endereco'];
    _ufController.text = pessoa['uf'];
    _municipioController.text = pessoa['municipio'];
    _uf = pessoa['uf'];
    _municipio = pessoa['municipio'];
    _isGerador = pessoa['gerador'];
    _isDestinador = pessoa['destinador'];
    _isTransportador = pessoa['transportador'];
  }

  void _resetFormFields() {
    _cpfCnpjController.clear;
    _nomeRazaoSocialController.clear;
    _telefoneController.clear;
    _emailController.clear;
    _enderecoController.clear;
    _ufController.clear;
    _municipioController.clear;

    _uf = null;
    _municipio = null;
    _isTransportador = false;
    _isGerador = false;
    _isDestinador = false;
    _isMotorista = false;
  }

  void _savePessoa() {
    if (_formKey.currentState!.validate()) {
      String errorMessage = '';

      if (_uf == null) {
        errorMessage += 'Selecione uma UF.\n';
      }
      if (_municipio == null) {
        errorMessage += 'Selecione um município.\n';
      }

      final Map<String, Object?> pessoa;

      if (_cpfCnpjController.text.length == 9) {
        pessoa = {
          'cpf': _cpfCnpjController.text,
          'nome': _nomeRazaoSocialController.text,
          'motorista': _isMotorista,
          'telefone': _telefoneController.text,
          'email': _emailController.text,
          'endereco': _enderecoController.text,
          'uf': _uf,
          'municipio': _municipio,
          'transportador': _isTransportador,
          'gerador': _isGerador,
          'destinador': _isDestinador
        };
      } else {
        pessoa = {
          'cnpj': _cpfCnpjController.text,
          'razaoSocial': _nomeRazaoSocialController.text,
          'motorista': false,
          'telefone': _telefoneController.text,
          'email': _emailController.text,
          'endereco': _enderecoController.text,
          'uf': _uf,
          'municipio': _municipio,
          'transportador': _isTransportador,
          'gerador': _isGerador,
          'destinador': _isDestinador,
        };
      }

      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        Navigator.pop(context, pessoa);
      }
    }
  }

  Future<void> _loadUFOptions() async {
    try {
      final response = await _ibgeService.getUFs();

      // Validar e acessar os dados da resposta
      if (response.containsKey('pessoas')) {
        ufOptions = (response['pessoas'] as List<dynamic>)
            .map((item) => {
                  'sigla': item['sigla'],
                  'nome': item['nome'],
                })
            .toList();
        setState(() {});
      } else {
        throw Exception(
            response['error'] ?? 'Erro desconhecido ao carregar UFs');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar opções de UF: $e'),
        ),
      );
    }
  }

  Future<void> _loadMunicipiosOptions(String uf) async {
    try {
      final response = await _ibgeService.getCities(uf);

      // Validar e acessar os dados da resposta
      if (response.containsKey('pessoas')) {
        municipioOptions = (response['pessoas'] as List<dynamic>)
            .map((item) => {
                  'id': item['id'].toString(),
                  'nome': item['nome'],
                })
            .toList();
        setState(() {});
      } else {
        throw Exception(
            response['error'] ?? 'Erro desconhecido ao carregar municípios');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar municípios para UF $uf: $e'),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o email.';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido.';
    }

    return null;
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
                        controller: _cpfCnpjController,
                        decoration:
                            const InputDecoration(labelText: 'CPF/CNPJ'),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira o CPF ou CPNJ'
                            : null,
                      ),
                      TextFormField(
                        controller: _nomeRazaoSocialController,
                        decoration: const InputDecoration(
                            labelText: 'Nome/Razão Social'),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira o nome ou razão social'
                            : null,
                      ),
                      TextFormField(
                        controller: _telefoneController,
                        decoration:
                            const InputDecoration(labelText: 'Telefone'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          PhoneInputFormatter(defaultCountryCode: 'BR'),
                        ],
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira o telefone'
                            : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType
                            .emailAddress, // Sugere teclado específico para e-mail
                        validator: _validateEmail,
                      ),
                      TypeAheadField<Map<String, dynamic>>(
                        suggestionsCallback: (search) => ufOptions
                            .where((option) =>
                                option['nome'].toString().contains(search))
                            .toList(),
                        controller: _ufController,
                        builder: (context, controller, focusNode) {
                          return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration:
                                  const InputDecoration(labelText: 'UF'));
                        },
                        itemBuilder: (context, value) {
                          return ListTile(
                            title: Text(
                                '${value['codigo']} - ${value['descricao']} '),
                          );
                        },
                        onSelected: (selection) async {
                          setState(() {
                            _uf = selection['sigla'];
                            _ufController.text =
                                '${selection['sigla']} - ${selection['nome']}';
                          });
                          await _loadMunicipiosOptions(_uf!);
                        },
                      ),
                      TypeAheadField<Map<String, dynamic>>(
                        suggestionsCallback: (search) => municipioOptions
                            .where((option) =>
                                option['descricao'].toString().contains(search))
                            .toList(),
                        controller: _municipioController,
                        builder: (context, controller, focusNode) {
                          return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                  labelText: 'Município'));
                        },
                        itemBuilder: (context, value) {
                          return ListTile(
                            title: Text('${value['nome']} '),
                          );
                        },
                        onSelected: (selection) {
                          setState(() {
                            _municipio = selection['nome'];
                            _municipioController.text = '${selection['nome']}';
                          });
                        },
                      ),
                      TextFormField(
                        controller: _enderecoController,
                        decoration:
                            const InputDecoration(labelText: 'Endereço'),
                        validator: (value) => value!.isEmpty
                            ? 'Por favor, insira o endereço'
                            : null,
                      ),
                      CheckboxListTile(
                        title: const Text('Transportador'),
                        value: _isTransportador,
                        onChanged: (value) {
                          setState(() {
                            _isTransportador = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Gerador'),
                        value: _isGerador,
                        onChanged: (value) {
                          setState(() {
                            _isGerador = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Destinador'),
                        value: _isDestinador,
                        onChanged: (value) {
                          setState(() {
                            _isDestinador = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Motorista'),
                        value: _isMotorista,
                        onChanged: (value) {
                          setState(() {
                            _isMotorista = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _savePessoa,
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
