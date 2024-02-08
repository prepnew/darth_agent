import 'package:darth_agent/input/clients/client_chunk_result.dart';
import 'package:darth_agent/input/clients/client_result.dart';
import 'package:darth_agent/input/clients/input_client.dart';

class ChatGPTClient extends InputClient {
  @override
  Future<List<double>> generateEmbeddings({
    required String model,
    required String prompt,
    Map<String, dynamic> options = const {},
    Map<String, dynamic>? headers = null,
    String? template = null,
    String? systemPrompt = null,
  }) {
    // TODO: implement generateEmbeddings
    throw UnimplementedError();
  }

  @override
  Future<ClientResult> generateResult({
    required String model,
    required String prompt,
    Map<String, dynamic> options = const {},
    Map<String, dynamic>? headers = null,
    String? template = null,
    String? systemPrompt = null,
  }) {
    // TODO: implement generateResult
    throw UnimplementedError();
  }

  @override
  Future<Stream<ClientChunkResult>> streamResult(
      {required String model,
      required String prompt,
      Map<String, dynamic> options = const {},
      Map<String, dynamic>? headers = null,
      String? template = null,
      String? systemPrompt = null}) {
    // TODO: implement streamResult
    throw UnimplementedError();
  }
}
