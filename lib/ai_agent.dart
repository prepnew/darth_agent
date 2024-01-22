library darth_agent;

import 'package:darth_agent/input/interpreter.dart';

import 'abilities/ability.dart';
import 'memory/memory.dart';
import 'memory/subject.dart';
import 'personalities/personality.dart';
import 'responses/agent_message.dart';
import 'responses/agent_response.dart';

/// Represents a complete AI agent, with abilities, memory and personality
class AIAgent {
  AIAgent({
    /// Input handler for prompts, using abilities defined for agent
    required this.interpreter,

    /// Skillset of agent, used to define what the agent can do
    required this.abilities,

    /// Set of external knowledge fed to the agent. Read only
    required this.subjects,

    /// Read/Write memory, internal knowledge it has - but bound to user in.
    /// Similar to short term memory or used in conversations
    required this.coreMemory,

    /// Long term memory from previous interactions with user or out of context
    /// conversations
    required this.archivalMemory,

    /// Optional personality for a more human-like agent
    this.personality,
  });

  final Interpreter interpreter;
  final List<Ability> abilities;
  final List<Subject> subjects;
  final Memory coreMemory;
  final Memory archivalMemory;
  final Personality? personality;

  /// Returns a completed response from the Agent
  Future<AgentResponse> requestResponse({required String prompt}) async {
    return Future.value(AgentResponse(message: 'test', tokens: 0));
  }

  /// Returns each intermediate response from the Agent, meaning every step and
  /// thought done to reach the final response
  Future<Stream<AgentMessage>> streamResponse({required String prompt}) async {
    // Fetch all functions from abilities and memories
    //functions.add(coreMemory.functionsDescription);
    //functions.add(archivalMemory.functionsDescription);
    final functionCallResponse = await interpreter.fetchFunctions(prompt: prompt, abilities: abilities);
    return Stream.fromIterable([
      AgentMessage(message: functionCallResponse),
    ]);
  }
}
