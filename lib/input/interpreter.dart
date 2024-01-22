import 'dart:io';

import 'package:darth_agent/ability/ability.dart';
import 'package:darth_agent/ability/basic/fallback.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:ollama_dart/ollama.dart';

import 'function_parser.dart';

/// Uses function calls in abilities with NexusRaven v2 model to figure out
/// which function to call. Should be used alongside GPT-4 function calling as
/// well when it works with opensource
class Interpreter {
  const Interpreter({required this.client, required this.functionParser});
  final Ollama client;
  final FunctionParser functionParser;

  Future<String> fetchFunctions({required String prompt, required List<Ability> abilities, required DebugType debug}) async {
    final time = DateTime.now().millisecondsSinceEpoch;
    if (debug.index > 0) stdout.writeln('User request: $prompt');
    final template = '''{{ .System }}\nUser Query: {{ .Prompt }}<human_end>''';
    abilities.add(FallBack());
    var systemPrompt = '';
    for (final ability in abilities) {
      systemPrompt += ability.functionsDescription;
    }
    final options = <String, dynamic>{
      'temperature': 0.001,
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
    final response = functionResult.response;
    final functionCall = response.substring(response.indexOf('Call: ') + 6, debug == DebugType.verbose ? response.indexOf('Thought:') : response.length).trim();
    if (debug.index > 0)
      stdout.writeln(
          'Function call:${debug == DebugType.verbose ? response : functionCall}\nFunction call used ${DateTime.now().millisecondsSinceEpoch - time} milliseconds to complete');
    final parsedFunctions = functionParser.parseFunctionCalls(functionCall);
    for (final func in parsedFunctions) {
      final functionName = func['function'];
      final arguments = func['arguments'];
      abilities.firstWhere((a) => a.functionName == functionName).functionCall(arguments);
    }
    return functionCall;
  }
}
