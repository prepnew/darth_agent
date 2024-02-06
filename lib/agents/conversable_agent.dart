import 'package:darth_agent/agents/agent.dart';

/// A class for generic conversable agents which can be configured as assistant
/// or user proxy
///
/// After receiving each message, the agent will send a reply to the sender
/// unless the msg is a termination msg. For example, AssistantAgent and
/// UserProxyAgent are subclasses of this class, configured with different
/// default settings.
abstract class ConversableAgent extends Agent {
  ConversableAgent({
    required super.name,
    this.systemMessage = "You are a helpful AI Assistant.",
    this.isTerminationMsg,
    this.maxConsecutiveAutoReply,
    this.humanInputMode = HumanInputMode.terminate,
    this.functionMap,
    this.codeExecutionConfig,
  });

  /// System message for the ChatCompletion inference.
  final String? systemMessage;

  /// Takes a message in the form of a dictionary and returns a boolean value
  /// indicating if this received message is a termination message.
  /// The dict can contain the following keys:
  /// "content", "role", "name", "function_call"
  final bool Function(Map<TerminationMessage, dynamic>)? isTerminationMsg;

  /// The maximum number of consecutive auto replies. default to null (no limit
  /// provided, class attribute MAX_CONSECUTIVE_AUTO_REPLY will be used as the
  /// limit in this case). When set to 0, no auto reply will be generated
  final int? maxConsecutiveAutoReply;

  /// Whether to ask for human inputs every time a message is received.
  final HumanInputMode humanInputMode;

  /// Mapping function names (passed to llm) to callable functions, also used
  /// for tool calls.
  final Map<String, Function>? functionMap;

  /// Config for the code execution. To disable code execution, set to false.
  /// Otherwise, set to a Map with the following keys:
  /// - workDir (Optional, str): The working directory for the code execution.
  ///   If None, a default working directory will be used. The default working
  ///   directory is the "extensions" directory under "path_to_autogen".
  /// - useDocker (Optional, list, str or bool): The docker image to use for
  ///   code execution. Default is True, which means the code will be executed
  ///   in a docker container. A default list of images will be used. If a list
  ///   or a str of image name(s) is provided, the code will be executed in a
  ///   docker container with the first image successfully pulled. If False,
  ///   the code will be executed in the current environment. We strongly
  ///   recommend using docker for code execution.
  /// - timeout (Optional, int): The maximum execution time in seconds.
  /// - lastNMessages (Experimental, int or str): The number of messages to
  ///   look back for code execution. If set to 'auto', it will scan backwards
  ///   through all messages arriving since the agent last spoke, which is
  ///   typically the last time execution was attempted. (Default: auto)
  final dynamic codeExecutionConfig;
}

enum HumanInputMode {
  /// the agent prompts for human input every time a message is received. Under
  /// this mode, the conversation stops when the human input is "exit", or when
  /// is_termination_msg is True and there is no human input.
  always,

  /// the agent only prompts for human input only when a termination message is
  /// received or the number of auto reply reaches the
  /// max_consecutive_auto_reply.
  terminate,

  /// the agent will never prompt for human input. Under this mode, the
  /// conversation stops when the number of auto reply reaches the
  /// max_consecutive_auto_reply or when is_termination_msg is True
  never,
}

enum TerminationMessage {
  content,
  role,
  name,
  functionCall,
}
