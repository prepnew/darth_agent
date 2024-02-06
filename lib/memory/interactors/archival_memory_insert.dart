import 'package:darth_agent/memory/neuro_link.dart';
import 'package:darth_agent/memory/util/embeddings_datastore.dart';
import 'package:darth_agent/utils/debug_type.dart';

/// Long term memory from previous interactions with user or whenever
/// conversations get too long and it needs to store it here to free up
class ArchivalMemoryInsert extends NeuroLink {
  @override
  String get name => 'archival_memory_insert';

  @override
  String get description => '''
Function:
def $name(content: str):
"""
Add to archival memory. Make sure to phrase the memory contents such that it can be easily queried later.

- content (str): Content to write to the memory. All unicode (including emojis) are supported.

Returns: Optional[str]: None is always returned as this function does not produce a response.
"""
''';

  @override
  Future access(
    EmbeddingsDataStore dataStore,
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async {}
}
