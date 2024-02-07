import 'dart:io';

import 'package:darth_agent/memory/simple/postgresql_db.dart';
import 'package:darth_agent/skills/net_dependent/location_check.dart';
import 'package:darth_agent/skills/net_dependent/weather_check.dart';
import 'package:darth_agent/agents/ai_agent.dart';
import 'package:darth_agent/env.dart';
import 'package:darth_agent/input/clients/ollama_client.dart';
import 'package:darth_agent/input/context_expander.dart';
import 'package:darth_agent/input/python_skill_parser.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:langchain_chroma/langchain_chroma.dart';

import '../implementations/chroma_conversation_memory.dart';
import '../implementations/chroma_datastore.dart';
import '../implementations/ollama_embeddings.dart';

// TODO: Rework ContextExpander to use a different model, nexusraven is not good enough
// It could give funny results thinking friday was a place, attempting to find weather in it with no reference to weather in prompt
const prompt = 'What is the temperature in Oslo right now?';

void main() async {
  final ollamaClient = OllamaClient(host: 'http://localhost');
  final aiAgent = AIAgent(
    name: 'Weather Agent',
    skills: [
      WeatherCheck(userAgent: Env.weatherUserAgent, dataStore: PostgresqlDb()),
      LocationCheck(locationApiKey: Env.locationApiKey, dataStore: PostgresqlDb()),
    ],
    memories: [
      ChromaConversationMemory(
          chromaDataStore: ChromaDataStore(
              chromaClient: Chroma(
        embeddings: OllamaEmbeddings(client: ollamaClient),
      )))
    ],
    contextRetriever: ContextExpander(
      client: ollamaClient,
      skillParser: PythonSkillParser(),
    ),
    debug: DebugType.none,
  );

  final response = await aiAgent.requestResponse(prompt: prompt);
  stdout.writeln(response.message);

  exit(1);
}
