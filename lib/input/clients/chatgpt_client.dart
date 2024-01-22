import 'package:darth_agent/input/clients/client_chunk_result.dart';
import 'package:darth_agent/input/clients/client_result.dart';
import 'package:darth_agent/input/clients/input_client.dart';

class ChatGPTClient extends InputClient {
  @override
  Future<ClientResult> generateResult(
      {required String prompt,
      required String model,
      required String systemPrompt,
      required String template,
      required Map<String, dynamic> options,
      Map<String, dynamic>? headers}) {
    // TODO: implement generateResult
    throw UnimplementedError();
  }

  @override
  Future<Stream<ClientChunkResult>> streamResult({
    required String prompt,
    required String model,
    required String systemPrompt,
    required String template,
    required Map<String, dynamic> options,
    Map<String, dynamic>? headers,
  }) {
    // TODO: implement streamResult
    throw UnimplementedError();
  }
}
