/// AI Agents style of communicating, defined as how it responds to prompts.
/// This can be expanded upon to create more dynamic and differing agents but
/// for now it is a simple extraneous variant that is added to system prompt for
/// the model responding to user
abstract class Personality {
  /// How the agent responds to prompts. Should only define its quirks and
  /// flavor, not specific handlings of prompts
  String get definition;
}
