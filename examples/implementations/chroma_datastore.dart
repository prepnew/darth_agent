import 'package:darth_agent/memory/util/embeddings_datastore.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_chroma/langchain_chroma.dart';

class ChromaDataStore extends EmbeddingsDataStore {
  ChromaDataStore({required this.chromaClient});
  final Chroma chromaClient;

  @override
  Future<List<VectorDocument>> search({required String query, int k = 1}) async {
    final result = await chromaClient.search(query: query, searchType: VectorStoreSearchType.mmr(k: k));
    return result.map((e) => VectorDocument(id: e.id, pageContent: e.pageContent, metadata: e.metadata)).toList(growable: false);
  }

  @override
  Future<List<VectorDocument>> similaritySearch(String query, {int k = 1}) async {
    final result = await chromaClient.similaritySearch(query: query, config: VectorStoreSimilaritySearch(k: k));
    return result.map((e) => VectorDocument(id: e.id, pageContent: e.pageContent, metadata: e.metadata)).toList(growable: false);
  }

  @override
  Future<List<String>> addDocuments({required List<VectorDocument> documents}) async => chromaClient.addDocuments(
        documents: documents
            .map((e) => Document(
                  id: e.id,
                  pageContent: e.pageContent,
                  metadata: e.metadata,
                ))
            .toList(),
      );
}
