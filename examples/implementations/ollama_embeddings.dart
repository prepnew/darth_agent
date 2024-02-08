import 'dart:io';

import 'package:darth_agent/input/clients/ollama_client.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:langchain/langchain.dart';

/// Uses the Ollama API to generate embeddings for documents and queries.
/// Ollama uses GPT4AllEmbeddings
class OllamaEmbeddings implements Embeddings {
  OllamaEmbeddings(
      {required this.model, required this.client, this.debug = DebugType.none});

  final String model;
  final OllamaClient client;
  final DebugType debug;

  @override
  Future<List<List<double>>> embedDocuments(List<Document> documents) async {
    final embeddings = <List<double>>[];
    if (debug.index > 1)
      stdout.writeln(
          'Embedding ${documents.length} documents - ${documents.map((e) => e.id)}');
    for (final document in documents) {
      embeddings.add(await client.generateEmbeddings(
          model: model, prompt: document.pageContent));
    }
    return embeddings;
  }

  @override
  Future<List<double>> embedQuery(String query) async {
    final embeddings =
        await client.generateEmbeddings(model: model, prompt: query);
    if (debug.index > 1) stdout.writeln('Embedding query: $query');
    return embeddings;
  }
}
