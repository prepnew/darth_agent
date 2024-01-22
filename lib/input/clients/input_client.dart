import 'package:darth_agent/input/clients/client_chunk_result.dart';

import 'client_result.dart';

abstract class InputClient {
  Future<ClientResult> generateResult({
    required String prompt,
    required String model,
    required String systemPrompt,
    required String template,
    required Map<String, dynamic> options,
    Map<String, dynamic>? headers,
  });

  Future<Stream<ClientChunkResult>> streamResult({
    required String prompt,
    required String model,
    required String systemPrompt,
    required String template,
    required Map<String, dynamic> options,
    Map<String, dynamic>? headers,
  });
}
