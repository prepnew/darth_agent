import 'package:darth_agent/memory/util/embeddings_datastore.dart';
import 'package:darth_agent/utils/debug_type.dart';

/// Represents a function to interact with the agent's memory
abstract class NeuroLink {
  /// Function name for the memory interactor
  String get name;

  /// Python function describing how
  String get description;

  /// The interaction with the dataStore. All memory storage is done through
  /// an embeddings data storage
  Future<dynamic> access(
    EmbeddingsDataStore dataStore,
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  });
}
