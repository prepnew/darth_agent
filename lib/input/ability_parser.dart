import 'package:darth_agent/ability/ability.dart';

/// Dynamic parser for function calls used in Interpreter for handling how a
/// given prompt should be functionally handled
abstract class AbilityParser {
  /// Inputs a string of function calls and returns a list of function calls
  List<AbilityCall> parseFunctionCalls(String functionCall, List<Ability> abilities);
}

/// Handles a single function call
class AbilityCall {
  AbilityCall({required this.ability, required this.arguments});
  final Ability ability;
  final Map<String, dynamic> arguments;
}
