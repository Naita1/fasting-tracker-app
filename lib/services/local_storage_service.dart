import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

class LocalStorageService {
  /// Inicializa o armazenamento local e abre todos os "boxes" (tabelas) necessários.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(AppConstants.userBox),
      Hive.openBox(AppConstants.fastingBox),
      Hive.openBox(AppConstants.mealsBox),
    ]);
  }

  /// Retorna a instância de um box já aberto na memória.
  Box _getBox(String boxName) => Hive.box(boxName);

  /// Salva ou atualiza um par de chave-valor no box especificado.
  Future<void> put(String boxName, String key, Map<String, dynamic> value) async {
    try {
      await _getBox(boxName).put(key, value);
    } catch (e) {
      throw Exception('Erro ao salvar no storage: $e');
    }
  }

  /// Recupera um valor baseado na chave. Retorna [null] se não existir.
  Map<String, dynamic>? get(String boxName, String key) {
    try {
      final data = _getBox(boxName).get(key);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception('Erro ao ler do storage: $e');
    }
  }

  /// Retorna todos os registros salvos em um box específico.
  List<Map<String, dynamic>> getAll(String boxName) {
    try {
      final box = _getBox(boxName);
      return box.values.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar lista do storage: $e');
    }
  }

  /// Remove um registro do banco de dados baseado na chave.
  Future<void> delete(String boxName, String key) async {
    try {
      await _getBox(boxName).delete(key);
    } catch (e) {
      throw Exception('Erro ao deletar do storage: $e');
    }
  }
}