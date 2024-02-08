import 'package:darth_agent/input/clients/client_chunk_result.dart';

import 'client_result.dart';

/// Handles
abstract class InputClient {
  Future<ClientResult> generateResult({
    required String model,
    required String prompt,
    Map<String, dynamic> options = const {},
    Map<String, dynamic>? headers = null,
    String? template = null,
    String? systemPrompt = null,
  });

  Future<Stream<ClientChunkResult>> streamResult({
    required String model,
    required String prompt,
    Map<String, dynamic> options = const {},
    Map<String, dynamic>? headers = null,
    String? template = null,
    String? systemPrompt = null,
  });

  Future<List<double>> generateEmbeddings({
    required String model,
    required String prompt,
    Map<String, dynamic> options = const {},
    Map<String, dynamic>? headers = null,
    String? template = null,
    String? systemPrompt = null,
  });
}
