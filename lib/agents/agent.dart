/// Start of AutoGen porting from
/// https://microsoft.github.io/autogen/docs/reference/agentchat/agent
abstract class Agent {
  Agent({required this.name});
  final String name;

  /// Send a message to an agent
  Future<void> send({
    required Map<String, dynamic> message,
    required String recipient,
    bool requestReply = false,
  });

  /// Receive a message from an agent
  Future<void> receive({
    required Map<String, dynamic> message,
    required String sender,
    bool request_reply = false,
  });

  void reset();

  /// Generate a reply based on the received messages.
  /// Returns: String, Map<String, dynamic> or null if no reply is generated
  Future<dynamic> generateReply({
    required List<Map<String, dynamic>>? messages,
    required Agent? sender,
  });
}
