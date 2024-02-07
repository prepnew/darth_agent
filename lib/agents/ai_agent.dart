library darth_agent;

import 'dart:io';

import 'package:darth_agent/input/context_expander.dart';
import 'package:darth_agent/memory/memory_bank.dart';
import 'package:darth_agent/utils/debug_type.dart';

import '../skills/skill.dart';
import '../memory/subject.dart';
import '../personality/personality.dart';
import '../response/agent_message.dart';
import '../response/agent_response.dart';

/// Represents a complete AI agent, with skills, memories, knowledge and traits
class AIAgent {
  AIAgent({
    required this.name,
    required this.contextRetriever,
    this.skills = const [],
    this.subjects = const [],
    this.memories = const [],
    this.personality,
    this.debug = DebugType.none,
  });

  final String name;

  /// Input handler for prompts, using skills defined for agent
  final ContextExpander contextRetriever;

  /// Skillset of agent, used to define what the agent can do
  final List<Skill> skills;

  /// Available memory banks for the agent. Usually only one will be relevant,
  /// the one coupled to the user
  final List<MemoryBank> memories;

  /// Set of external knowledge fed to the agent. Read only
  final List<Subject> subjects;

  /// Optional personality/trait for a more human-like agent. Skipped for now.
  final Personality? personality;

  /// Whether to print debug information or not
  final DebugType debug;

  /// Returns a completed response from the Agent
  Future<AgentResponse> requestResponse({required String prompt}) async {
    /// Populated context for getting a good answer combined with prompt
    final retrievedContext = await contextRetriever.retrieveContext(
      prompt: prompt,
      skills: skills,
      memories: memories,
      subjects: subjects,
      debug: debug,
    );
    if (debug.index > 0) stdout.writeln('Context retrieved:\n$retrievedContext');

    /// Send context along with prompt to the model used for response generation
    return Future.value(AgentResponse(message: retrievedContext, tokens: 0));
  }

  /// Returns each intermediate response from the Agent, meaning every step and
  /// thought done to reach the final response
  Future<Stream<AgentMessage>> streamResponse({required String prompt}) async {
    /// Populated context for getting a good answer combined with prompt
    final retrievedContext = await contextRetriever.retrieveContext(
      prompt: prompt,
      skills: skills,
      memories: memories,
      subjects: subjects,
      debug: debug,
    );
    if (debug.index > 0) stdout.writeln('Context retrieved:\n$retrievedContext');

    /// Send context along with prompt to the model used for response generation

    return Stream.fromIterable([
      AgentMessage(message: retrievedContext),
    ]);
  }
}
