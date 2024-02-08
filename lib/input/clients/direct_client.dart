import 'package:darth_agent/input/clients/client_chunk_result.dart';
import 'package:darth_agent/input/clients/client_result.dart';
import 'package:darth_agent/input/clients/input_client.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

/// Uses llama.cpp through llama_cpp_dart to generate results
class DirectClient extends InputClient {
  DirectClient({
    required String modelPath,
    required this.contextParams,
    ModelParams? modelParams,
    SamplingParams? samplingParams,
    this.isBackend = true,
  })  : this.modelParams = modelParams ?? ModelParams(),
        this.samplingParams = samplingParams ?? SamplingParams();
  final ContextParams contextParams;
  final ModelParams modelParams;
  final SamplingParams samplingParams;
  final bool isBackend;
  Llama? llama;
  LlamaProcessor? processor;

  Future<void> preloadModel({required String modelPath}) async {
    if (isBackend) {
      llama = Llama(modelPath, modelParams, contextParams, samplingParams);
    } else {
      processor = LlamaProcessor(
        modelPath,
        modelParams,
        contextParams,
        samplingParams,
      );
    }
  }

  void dispose() {
    llama?.clear();
    llama?.dispose();
    processor?.stop();
    processor?.unloadModel();
  }

  @override
  Future<List<double>> generateEmbeddings(
      {required String model,
      required String prompt,
      Map<String, dynamic> options = const {},
      Map<String, dynamic>? headers = null,
      String? template = null,
      String? systemPrompt = null}) {
    // TODO: implement generateEmbeddings
    throw UnimplementedError();
  }

  @override
  Future<ClientResult> generateResult(
      {required String model,
      required String prompt,
      Map<String, dynamic> options = const {},
      Map<String, dynamic>? headers = null,
      String? template = null,
      String? systemPrompt = null}) {
    // TODO: implement generateResult
    throw UnimplementedError();
  }

  @override
  Future<Stream<ClientChunkResult>> streamResult({
    required String model,
    required String prompt,
    Map<String, dynamic> options = const {},
    Map<String, dynamic>? headers = null,
    String? template = null,
    String? systemPrompt = null,
  }) async {
    if (isBackend) {
      llama!.clear();
      llama!.setPrompt(prompt);
      final stream = llama!.prompt(prompt);
      return stream.map((event) => ClientChunkResult());
    } else {
      processor!.prompt(prompt);
      return processor!.stream.map((event) => ClientChunkResult());
    }
  }
}
