import 'package:darth_agent/skills/skill.dart';
import 'package:darth_agent/utils/debug_type.dart';

/// Locates a file on the local system. Need to handle operating system.
class FindFile extends Skill {
  @override
  String get name => 'locate_local_file';

  @override
  String get description => '''
Function:
def $name(file_name: str):
"""
Searches the local file system for a file with the given name.

- file_name (str): The name of the file to search for.

Returns: str: The path to the file if found, else returns None.
"""
''';

  @override
  Future use(
    Map<String, dynamic> args, {
    bool llmOutput = true,
    DebugType debug = DebugType.none,
  }) async {}
}
