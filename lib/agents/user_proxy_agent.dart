import 'package:darth_agent/agents/conversable_agent.dart';

/// A proxy agent for the user, that can execute code and provide feedback to
/// the other agents.
abstract class UserProxyAgent extends ConversableAgent {
  UserProxyAgent({required super.name});
}
