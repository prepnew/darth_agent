import 'package:darth_agent/skills/skill.dart';
import 'package:darth_agent/utils/debug_type.dart';

/// Checks internet for information. Will be hard to implement as it is not
/// something that can be scraped through curl or similar.
/// Returns a string if something is found, else returns null
class InformationFinder extends Skill {
  @override
  String get name => 'google_search';

  @override
  String get description => '''
Function:
def $name(subject: str):
"""
Googles the internet for information about a given subject.

- subject (str): The information the user wants to know more about.

Returns: str: Information about the subject parsed as lines.
"""
''';

  @override
  Future<dynamic> use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async {
    return 'Found nuthin!!';
  }
}
