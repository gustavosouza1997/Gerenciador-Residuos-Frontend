import '../services/mtr_service.dart';

class MTRPresenter {
  final MTRService _mtrService = MTRService();

  Future<Map<String, List<Map<String, dynamic>>>> fetchOptions() async {
    try {
      final acondicionamentoOptions =
          (await _mtrService.fetchAcondicionamento())
              .map((item) => {
                    'codigo': item['tipoCodigo'].toString(),
                    'descricao': item['tipoDescricao'],
                  })
              .toList();

      final classeOptions = (await _mtrService.fetchClasse())
          .map((item) => {
                'codigo': item['tpclaCodigo'].toString(),
                'descricao': item['tpclaDescricao'],
              })
          .toList();

      final estadoFisicoOptions = (await _mtrService.fetchEstadoFisico())
          .map((item) => {
                'codigo': item['tpestCodigo'].toString(),
                'descricao': item['tpestDescricao'],
              })
          .toList();

      final tecnologiaOptions = (await _mtrService.fetchTecnologia())
          .map((item) => {
                'codigo': item['tipoCodigo'].toString(),
                'descricao': item['tipoDescricao'],
              })
          .toList();

      final unidadeOptions = (await _mtrService.fetchUnidade())
          .map((item) => {
                'codigo': item['tpuniCodigo'].toString(),
                'descricao': item['tpuniDescricao'],
              })
          .toList();

      final residuoOptions = (await _mtrService.fetchResiduo())
          .map((item) => {
                'codigo': item['tpre3Numero'],
                'descricao': item['tpre3Descricao'],
              })
          .toList();

      return {
        'acondicionamento': acondicionamentoOptions,
        'classe': classeOptions,
        'estadoFisico': estadoFisicoOptions,
        'tecnologia': tecnologiaOptions,
        'unidade': unidadeOptions,
        'residuo': residuoOptions,
      };
    } catch (e) {
      throw Exception('Erro ao carregar opções: $e');
    }
  }

  Future<List<Map<String, dynamic>>> salvarManifesto(Map<String, dynamic> manifestoDto) async {
    try {
      final result = await _mtrService.salvarManifestoLote(manifestoDto);
      return result;
    } catch (e) {
      throw Exception('Erro ao salvar manifesto: $e');
    }
  }
}
