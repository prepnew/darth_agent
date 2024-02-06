import 'dart:io';

import 'package:darth_agent/memory/memory_bank.dart';
import 'package:darth_agent/memory/subject.dart';
import 'package:darth_agent/skills/skill.dart';
import 'package:darth_agent/skills/basic/fallback.dart';
import 'package:darth_agent/input/clients/input_client.dart';
import 'package:darth_agent/utils/debug_type.dart';

import 'skill_parser.dart';

/// Uses function calls in abilities with a parser for function calls so that it
/// can access its abilities and call any that might be needed
class ContextExpander {
  const ContextExpander({required this.client, required this.skillParser});
  final InputClient client;
  final SkillParser skillParser;

  /// Fetches as much context as possible to flesh out final response by calling
  /// abilities. Sends prompt through agents available skills, its memories and
  /// its available subjects. Returns a string with line separated results from
  /// each
  Future<String> retrieveContext(
      {required String prompt,
      required List<Skill> skills,
      required List<MemoryBank> memories,
      required List<Subject> subjects,
      required DebugType debug,
      double temperature = 0.001}) async {
    final context = <String>[];
    final time = DateTime.now().millisecondsSinceEpoch;
    if (debug.index > 0) stdout.writeln('User request for context expanding: $prompt');
    // TODO: Template is specific for nexusraven. Need a similar template for ChatGPT
    final template = '''{{ .System }}\nUser Query: {{ .Prompt }}<human_end>''';
    // TODO: Fallback function is not model agnostic and bound to PythonParser for NexusRaven. Need a similar function for ChatGPT
    skills.add(FallBack());

    // Adding all skill descriptions to system prompt
    // TODO: This is also not model agnostic and will not work for ChatGPT
    var systemPrompt = '';
    for (final skill in skills) {
      systemPrompt += skill.description;
    }

    // Low temperature to have no deviation
    final options = <String, dynamic>{
      'temperature': temperature,
    };
    if (debug != DebugType.verbose) {
      options['stop'] = ['Thought:'];
    }
    client.setupGeneration(
      model: 'nexusraven',
      systemPrompt: systemPrompt,
      template: template,
      options: options,
    );

    /// Start by generating context from function calls. If no function calls
    /// then move on to memories and subjects
    final functionResult = await client.generateResult(prompt: prompt);
    final response = functionResult.choices.first.message.content;
    final skillCheck = response.substring(response.indexOf('Call: ') + 6, debug == DebugType.verbose ? response.indexOf('Thought:') : response.length).trim();
    if (debug.index > 0)
      stdout.writeln(
          'Skill check:${debug == DebugType.verbose ? response : skillCheck}\nSkill used ${DateTime.now().millisecondsSinceEpoch - time} milliseconds to complete');
    for (final parsed in skillParser.parseSkills(skillCheck, skills)) {
      context.add(await parsed.skill.use(parsed.arguments, debug: debug));
    }

    /// Finding memories or manipulates memory based on prompt
    for (final memoryBank in memories) {
      systemPrompt = '';
      for (final neurolink in memoryBank.memoryInteractors) {
        systemPrompt += neurolink.description;
      }
      stdout.writeln('Memory system prompt: $systemPrompt');
      client.setupGeneration(
        model: 'nexusraven',
        systemPrompt: systemPrompt,
        template: template,
        options: options,
      );

      /// Memory interaction decided
      final memoryResult = await client.generateResult(prompt: prompt);
      final memoryResponse = memoryResult.choices.first.message.content;
      stdout.writeln('Memory result: $memoryResponse');
    }

    return context.join('\n');
  }
}
