/// Represents the agent's memory, which is used to store information about the
/// user or interactions with the world. This should be partitioned into each
/// user accessing so that they are not able to access each other's memory.
/// To store data, a vector database is used much the same as MEMGpt
class Memory {
  Memory({required this.functionsDescription});

  /// Functions memory uses to read or write in memory with
  final String functionsDescription;
}
