import 'dart:io';

import 'package:darth_agent/ability/basic/location_check.dart';
import 'package:darth_agent/ability/basic/weather_check.dart';
import 'package:darth_agent/ai_agent.dart';
import 'package:darth_agent/env.dart';
import 'package:darth_agent/input/clients/ollama_client.dart';
import 'package:darth_agent/input/interpreter.dart';
import 'package:darth_agent/input/python_ability_parser.dart';
import 'package:darth_agent/memory/long_term/archival_memory.dart';
import 'package:darth_agent/memory/short_term/core_memory.dart';
import 'package:darth_agent/utils/debug_type.dart';

const prompt = 'What is the temperature in Longyearbyen right now?';

void main() async {
  final aiAgent = AIAgent(
    abilities: [WeatherCheck(userAgent: Env.weatherUserAgent), LocationCheck(locationApiKey: Env.locationApiKey)],
    coreMemory: CoreMemory(),
    subjects: [],
    archivalMemory: ArchivalMemory(),
    interpreter: Interpreter(
      client: OllamaClient(host: 'http://localhost'),
      functionParser: PythonAbilityParser(),
    ),
    debug: DebugType.basic,
  );

  final response = await aiAgent.requestResponse(prompt: prompt);
  stdout.writeln(response.message);

  exit(1);
}
