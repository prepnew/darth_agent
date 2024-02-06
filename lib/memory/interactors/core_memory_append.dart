import 'package:darth_agent/memory/neuro_link.dart';
import 'package:darth_agent/memory/util/embeddings_datastore.dart';
import 'package:darth_agent/utils/debug_type.dart';

/// Memory bound to user info and interactions. Used as short term memory
class CoreMemoryAppend extends NeuroLink {
  @override
  String get name => 'core_memory_append';

  @override
  String get description => '''
Function:
def $name(name: str, content: str):
"""
Append to the contents of core memory.

- name (str): Section of the memory to be edited (persona or human).
- content (str): Content to write to the memory. All unicode (including emojis) are supported.

Returns: Optional[str]: None is always returned as this function does not produce a response.
''';

  @override
  Future access(
    EmbeddingsDataStore dataStore,
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async {}
}
