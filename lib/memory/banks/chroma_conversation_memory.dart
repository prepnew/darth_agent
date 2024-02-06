import 'package:darth_agent/memory/interactors/archival_memory_insert.dart';
import 'package:darth_agent/memory/interactors/archival_memory_search.dart';
import 'package:darth_agent/memory/interactors/core_append_memory.dart';
import 'package:darth_agent/memory/interactors/core_replace_memory.dart';
import 'package:darth_agent/memory/memory_bank.dart';
import 'package:darth_agent/memory/util/chroma_datastore.dart';

/// Stores and interacts with a ChromaDB memory with a basic memory interaction
class ChromaConversationMemory extends MemoryBank {
  ChromaConversationMemory({
    required ChromaDataStore chromaDataStore,
  }) : super(
          memoryInteractors: [
            CoreAppendMemory(),
            CoreReplaceMemory(),
            ArchivalMemoryInsert(),
            ArchivalMemorySearch(),
          ],
          dataStore: chromaDataStore,
        );
}
