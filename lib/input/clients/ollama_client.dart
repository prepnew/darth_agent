import 'package:darth_agent/input/clients/client_chunk_result.dart';
import 'package:darth_agent/input/clients/client_result.dart';
import 'package:darth_agent/input/clients/input_client.dart';
import 'package:http/http.dart' as http;
import 'package:ollama_dart/domain/chunk.dart';
import 'package:ollama_dart/domain/result.dart';
import 'package:ollama_dart/ollama.dart';
import 'package:uuid/uuid.dart';

class OllamaClient extends InputClient {
  OllamaClient({required String host, int port = 11434, http.Client? client})
      : ollama = Ollama(
          host: host,
          port: port,
          client: client,
        );
  final Ollama ollama;

  @override
  Future<ClientResult> generateResult({
    required String prompt,
  }) async {
    final result = await ollama.generateResult(
      prompt: prompt,
      model: model!,
      systemPrompt: systemPrompt,
      template: template,
      options: options,
    );
    return result.toClientResult(model!);
  }

  @override
  Future<Stream<ClientChunkResult>> streamResult({
    required String prompt,
  }) async {
    final stream = await ollama.generateStream(
      prompt: prompt,
      model: model!,
      systemPrompt: systemPrompt,
    );
    return stream.map((chunk) => chunk.toClientChunkResult(model!));
  }

  @override
  Future<List<double>> generateEmbeddings({required String prompt}) async {
    // TODO: Add options properly
    final ollamaEmdeddings = await ollama.generateEmbeddings(
      model!,
      prompt,
      options: null,
    );
    return ollamaEmdeddings.embeddings;
  }
}

extension _OllamaResultExtension on Result {
  ClientResult toClientResult(String model) {
    return ClientResult(
      id: Uuid().v4(),
      object: 'chat.completion',
      created: DateTime.parse(createdAt).millisecondsSinceEpoch ~/ 1000,
      model: model,
      system_fingerprint: 'unsupported',
      choices: [
        Choice(
          index: 0,
          message: Message(
            content: response,
            role: 'assistant',
          ),
          finish_reason: 'stop',
          logprobs: null,
        )
      ],
      usage: Usage(
        prompt_tokens: promptEvalCount ?? 0,
        completion_tokens: evalCount ?? 0,
        total_tokens: ((promptEvalCount ?? 0) + (evalCount ?? 0)),
      ),
    );
  }
}

extension _OllamaChunkResultExtension on Chunk {
  ClientChunkResult toClientChunkResult(String model) {
    return ClientChunkResult();
  }
}
