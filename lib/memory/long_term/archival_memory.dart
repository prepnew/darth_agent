import 'package:darth_agent/memory/memory.dart';

/// Long term memory from previous interactions with user or whenever
/// conversations get too long and it needs to store it here to free up
class ArchivalMemory extends Memory {
  ArchivalMemory() : super(functionsDescription: '');
}
