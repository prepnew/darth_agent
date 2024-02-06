import 'package:darth_agent/skills/skill.dart';
import 'package:darth_agent/utils/debug_type.dart';

/// Should be part of every agent if it should function as an agent that is able
/// to NOT use abilities. If NO other abilities matches the user input, this
/// should be called by the agent to inform the system that this should be
/// solved by the main model without any extra information. It shortcircuits the
/// llm to not choose an invalid ability in vain
class FallBack extends Skill {
  @override
  String get name => 'fallback';

  @override
  String get description => '''
Function:
def $name():
"""
No other matching function wwas found. This function is used if no match is available.

No arguments.

Returns: Optional[str]: None is always returned as this function does not produce a response.
"""
''';

  @override
  Future use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async =>
      '';
}
