import 'dart:io';

import 'package:darth_agent/ability/ability.dart';
import 'package:darth_agent/ability/basic/fallback.dart';
import 'package:darth_agent/input/clients/input_client.dart';
import 'package:darth_agent/utils/debug_type.dart';

import 'ability_parser.dart';

/// Uses function calls in abilities with a parser for function calls so that it
/// can access its abilities and call any that might be needed
class Interpreter {
  const Interpreter({required this.client, required this.functionParser});
  final InputClient client;
  final AbilityParser functionParser;

  Future<String> fetchFunctions({required String prompt, required List<Ability> abilities, required DebugType debug, double temperature = 0.001}) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    if (debug.index > 0) stdout.writeln('User request: $prompt');
    // TODO: Template is specific for nexusraven. Need a similar template for ChatGPT
    final template = '''{{ .System }}\nUser Query: {{ .Prompt }}<human_end>''';
    // TODO: Fallback function is not model agnostic and bound to PythonParser for NexusRaven. Need a similar function for ChatGPT
    abilities.add(FallBack());

    // Adding all ability descriptions to system prompt
    // TODO: This is also not model agnostic and will not work for ChatGPT
    var systemPrompt = '';
    for (final ability in abilities) {
      systemPrompt += ability.functionsDescription;
    }

    // Low temperature to have no deviation
    final options = <String, dynamic>{
      'temperature': temperature,
    };
    if (debug != DebugType.verbose) {
      options['stop'] = ['Thought:'];
    }

    final functionResult = await client.generateResult(
      prompt: prompt,
      model: 'nexusraven',
      systemPrompt: systemPrompt,
      template: template,
      options: options,
    );
    final response = functionResult.choices.first.message.content;
    final functionCall = response.substring(response.indexOf('Call: ') + 6, debug == DebugType.verbose ? response.indexOf('Thought:') : response.length).trim();
    if (debug.index > 0)
      stdout.writeln(
          'Function call:${debug == DebugType.verbose ? response : functionCall}\nFunction call used ${DateTime.now().millisecondsSinceEpoch - time} milliseconds to complete');
    final parsedFunctions = functionParser.parseFunctionCalls(functionCall, abilities);
    for (final func in parsedFunctions) {
      final ability = func.ability;
      stdout.writeln('Calling function: ${ability.functionName} with arguments: ${func.arguments}');
      final result = await ability.functionCall(func.arguments);
      stdout.writeln('Result from ${ability.functionName}: $result');
    }
    return functionCall;
  }
}
