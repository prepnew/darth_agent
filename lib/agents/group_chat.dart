import 'package:darth_agent/agents/agent.dart';

class GroupChat {
  GroupChat({
    required this.agents,
    required this.maxRound,
    this.adminName = "Admin",
    this.funcCallFilter = true,
    this.speakerSelectionMethod = SpeakerSelectionMethod.auto,
    this.allowRepeatSpeaker = true,
    this.allowedOrDisallowedSpeakerTransitions = null,
    this.speakerTransitionsType = null,
    this.enableClearHistory = false,
  });

  /// a list of participating agents.
  final List<Agent> agents;

  /// a list of messages in the group chat.
  final List<String> messages = [];

  /// the maximum number of rounds.
  final int maxRound;

  /// the name of the admin agent if there is one. Default is "Admin".
  /// KeyBoardInterrupt will make the admin agent take over.
  final String adminName;

  /// whether to enforce function call filter. Default is True. When set to True
  /// and when a message is a function call suggestion, the next speaker will be
  /// chosen from an agent which contains the corresponding function name in its
  /// function_map
  final bool funcCallFilter;

  /// The method for selecting the next speaker. Default is
  /// [SpeakerSelectionMethod.auto].
  final SpeakerSelectionMethod speakerSelectionMethod;

  /// Whether to allow the same speaker to speak consecutively. Default is True,
  /// in which case all speakers are allowed to speak consecutively. If
  /// [allowRepeatSpeaker] is a list of Agents, then only those listed agents
  /// are allowed to repeat. If set to False, then no speakers are allowed to
  /// repeat. [allowRepeatSpeaker] and [allowedOrDisallowedSpeakerTransitions]
  /// are mutually exclusive.
  final dynamic allowRepeatSpeaker;

  /// The keys are source agents, and the values are agents that the key agent
  /// can/can't transit to, depending on [speakerTransitionsType]. Default is
  /// null, which means all agents can transit to all other agents.
  /// [allowRepeatSpeaker] and [allowedOrDisallowedSpeakerTransitions] are
  /// mutually exclusive
  final dynamic allowedOrDisallowedSpeakerTransitions;

  /// Whether the [speakerTransitionsType] is a dictionary containing lists of
  /// allowed agents or disallowed agents. "allowed" means the
  /// [allowedOrDisallowedSpeakerTransitions] is a dictionary containing lists
  /// of allowed agents. If set to "disallowed", then the
  /// [allowedOrDisallowedSpeakerTransitions] is a dictionary containing lists
  /// of disallowed agents. Must be supplied if
  /// [allowedOrDisallowedSpeakerTransitions] is not null.
  final dynamic speakerTransitionsType;

  /// Enable possibility to clear history of messages for agents manually by
  /// providing "clear history" phrase in user prompt. This is experimental
  /// feature. See description of agents0 function for more info.
  final bool enableClearHistory;

  /// Append a message to the group chat. We cast the content to str here so
  /// that it can be managed by text-based model.
  void append(Map<String, dynamic> message, Agent speaker) {}

  /// Returns the agent with a given name.
  Agent agentByName({required String name}) =>
      agents.firstWhere((agent) => agent.name == name);

  /// Return the next agent in the list.
  Agent nextAgent(Agent agent, {List<Agent>? agents}) {
    final list = agents ?? this.agents;
    final index = list.indexOf(agent);
    return list[(index + 1) % list.length];
  }
}

enum SpeakerSelectionMethod {
  /// the next speaker is selected automatically by LLM.
  auto,

  /// the next speaker is selected manually by user input.
  manual,

  /// the next speaker is selected randomly.
  random,

  /// the next speaker is selected in a round robin fashion, i.e., iterating in
  /// the same order as provided in agents.
  roundRobin,
}
