import 'dart:io';

import 'package:darth_agent/ability/basic/city_location.dart';
import 'package:darth_agent/ability/basic/weather_check.dart';
import 'package:darth_agent/ai_agent.dart';
import 'package:darth_agent/input/function_parser.dart';
import 'package:darth_agent/input/interpreter.dart';
import 'package:darth_agent/memory/long_term/archival_memory.dart';
import 'package:darth_agent/memory/short_term/core_memory.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:ollama_dart/ollama.dart';

const prompt = 'What is the temperature in Oslo right now?';

void main() async {
  final aiAgent = AIAgent(
    abilities: [WeatherCheck(), CityLocation()],
    coreMemory: CoreMemory(),
    subjects: [],
    archivalMemory: ArchivalMemory(),
    interpreter: Interpreter(
      client: Ollama(host: 'http://localhost'),
      functionParser: FunctionParser(),
    ),
    debug: DebugType.none,
  );

  final response = await aiAgent.requestResponse(prompt: prompt);
  stdout.writeln(response.message);

  exit(1);
}
