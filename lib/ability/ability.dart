/// Represents an agent's ability to do something. This is representative of a
/// set of function calls that can be executed and is required for the system
/// prompt. The ability itself also needs the tools to perform said ability.
/// For reference, check NexusRaven's prompting guide or go to
/// https://huggingface.co/Nexusflow/NexusRaven-13B/blob/main/prompting_readme.md
/// for a quick tutorial
abstract class Ability {
  /// The name of the ability, used to match up with the function call
  String get functionName;

  /// Python functions description with descrription in """ """ as docString
  String get functionsDescription;

  /// Function call used by LLM, can be any type and any number of arguments
  /// Arguments come in json format. Check function_parser.dart for more info
  Future<dynamic> call(Map<String, dynamic> args, {bool llmOutput = true});
}
