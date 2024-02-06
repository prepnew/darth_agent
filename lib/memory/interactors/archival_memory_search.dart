import 'package:darth_agent/memory/neuro_link.dart';
import 'package:darth_agent/memory/util/embeddings_datastore.dart';
import 'package:darth_agent/utils/debug_type.dart';

class ArchivalMemorySearch extends NeuroLink {
  @override
  String get name => 'archival_memory_search';

  @override
  String get description => '''
Function:
def $name(query: str, page: Optional[int] = 0):
"""
Search archival memory using semantic (embedding-based) search.

- query (str): String to search for.
- page (Optional[int]): Allows you to page through results. Only use on a follow-up query. Defaults to 0 (first page).

 Returns: str: Query result string
''';

  @override
  Future access(
    EmbeddingsDataStore dataStore,
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async {}
}
