import 'package:darth_agent/input/clients/client_chunk_result.dart';
import 'package:darth_agent/input/clients/client_result.dart';
import 'package:darth_agent/input/clients/input_client.dart';

class ChatGPTClient extends InputClient {
  @override
  Future<ClientResult> generateResult({required String prompt}) {
    // TODO: implement generateResult
    throw UnimplementedError();
  }

  @override
  Future<Stream<ClientChunkResult>> streamResult({required String prompt}) {
    // TODO: implement streamResult
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic>? headers;

  @override
  Map<String, dynamic> options = {};

  @override
  String? systemPrompt;

  @override
  String? template;

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
