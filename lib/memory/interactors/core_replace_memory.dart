import 'package:darth_agent/memory/neuro_link.dart';
import 'package:darth_agent/memory/util/embeddings_datastore.dart';
import 'package:darth_agent/utils/debug_type.dart';

class CoreReplaceMemory extends NeuroLink {
  @override
  String get name => 'core_memory_replace';

  @override
  String get description => '''
Function:
def $name(name: str, old_content: str, new_content: str):
"""
Replace to the contents of core memory. To delete memories, use an empty string for new_content.

- name (str): Section of the memory to be edited (persona or human).
- old_content (str): String to replace. Must be an exact match.
- new_content (str): Content to write to the memory. All unicode (including emojis) are supported.

Returns: Optional[str]: None is always returned as this function does not produce a response.
"""
''';

  @override
  Future access(EmbeddingsDataStore dataStore, Map<String, dynamic> args, {bool llmOutput = true, DebugType debug = DebugType.none}) async {}
}
