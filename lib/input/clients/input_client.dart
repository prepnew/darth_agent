import 'package:darth_agent/input/clients/client_chunk_result.dart';

import 'client_result.dart';

abstract class InputClient {
  Future<void> setupGeneration(
      {String? model,
      String? modelPath,
      String? systemPrompt,
      String? template,
      Map<String, dynamic> options = const {},
      Map<String, dynamic>? headers}) async {
    this.model = model;
    this.modelPath = modelPath;
    this.systemPrompt = systemPrompt;
    this.template = template;
    this.options = options;
    this.headers = headers;
  }

  Future<void> preloadModel({String? model, String? modelPath}) async {}

  String? model;
  String? modelPath;

  String? systemPrompt = null;

  String? template = null;

  Map<String, dynamic> options = {};

  Map<String, dynamic>? headers = null;

  Future<ClientResult> generateResult({required String prompt});

  Future<Stream<ClientChunkResult>> streamResult({required String prompt});

  Future<List<double>> generateEmbeddings({required String prompt});

  void dispose() {}
}
