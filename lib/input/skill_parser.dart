import 'package:darth_agent/skills/skill.dart';

/// Dynamic parser for function calls used in Interpreter for handling how a
/// given prompt should be functionally handled
abstract class SkillParser {
  /// Inputs a string of function calls and returns a list of function calls
  List<SkillUse> parseSkills(String skillName, List<Skill> abilities);
}

/// Handles a single skill use
class SkillUse {
  SkillUse({required this.skill, required this.arguments});
  final Skill skill;
  final Map<String, dynamic> arguments;

  @override
  String toString() {
    return 'Skill==>${skill.name}($arguments)';
  }
}
