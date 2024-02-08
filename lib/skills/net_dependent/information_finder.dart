import 'dart:io';

import 'package:darth_agent/skills/skill.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:http/http.dart' as http;

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
    final subject = args['subject'].replaceAll(' ', '+');
    final response = await http
        .get(Uri.parse('https://duckduckgo.com/?t=h_&q=$subject&ia=web'));
    stdout.writeln(response.body);
    return 'A search in the web was done, but no relevant information was found about "".';
  }
}
