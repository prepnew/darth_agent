import 'package:darth_agent/memory/neuro_link.dart';
import 'package:darth_agent/memory/util/embeddings_datastore.dart';

/// A memory bank is a collection of data storage and functionality to interact
/// with the storage
class MemoryBank {
  MemoryBank({required this.memoryInteractors, required this.dataStore});
  final List<NeuroLink> memoryInteractors;
  final EmbeddingsDataStore dataStore;
}
