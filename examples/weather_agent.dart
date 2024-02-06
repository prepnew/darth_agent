import 'dart:io';

import 'package:darth_agent/input/embeddings/ollama_embeddings.dart';
import 'package:darth_agent/memory/banks/chroma_conversation_memory.dart';
import 'package:darth_agent/memory/simple/postgresql_db.dart';
import 'package:darth_agent/memory/util/chroma_datastore.dart';
import 'package:darth_agent/skills/net_dependent/location_check.dart';
import 'package:darth_agent/skills/net_dependent/weather_check.dart';
import 'package:darth_agent/agents/ai_agent.dart';
import 'package:darth_agent/env.dart';
import 'package:darth_agent/input/clients/ollama_client.dart';
import 'package:darth_agent/input/context_expander.dart';
import 'package:darth_agent/input/python_skill_parser.dart';
import 'package:darth_agent/utils/debug_type.dart';
import 'package:langchain_chroma/langchain_chroma.dart';

const prompt = 'Tell me what I like to eat on fridays'; //'What is the temperature in Oslo right now?';

void main() async {
  final ollamaClient = OllamaClient(host: 'http://localhost');
  final aiAgent = AIAgent(
    name: 'Weather Agent',
    skills: [
      WeatherCheck(userAgent: Env.weatherUserAgent, dataStore: PostgresqlDb()),
      LocationCheck(locationApiKey: Env.locationApiKey, dataStore: PostgresqlDb()),
    ],
    memories: [ChromaConversationMemory(chromaDataStore: ChromaDataStore(chromaClient: Chroma(embeddings: OllamaEmbeddings(client: ollamaClient))))],
    subjects: [],
    contextRetriever: ContextExpander(
      client: ollamaClient,
      skillParser: PythonSkillParser(),
    ),
    debug: DebugType.basic,
  );

  final response = await aiAgent.requestResponse(prompt: prompt);
  stdout.writeln(response.message);

  exit(1);
}
