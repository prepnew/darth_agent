abstract class EmbeddingsDataStore {
  Future<List<VectorDocument>> search({required String query});
  Future<List<VectorDocument>> similaritySearch(String query, {int k = 1});

  Future<List<String>> addDocuments({required List<VectorDocument> documents});
}

/// Abstraction of any vector database document
class VectorDocument {
  VectorDocument({
    required this.id,
    required this.pageContent,
    required this.metadata,
  });

  /// Can be used to identify document
  final String? id;

  /// The text content of the document.
  final String pageContent;

  /// The metadata of the document.
  final Map<String, dynamic> metadata;
}
