final functionAndArgumentsRegex = RegExp(r'(\w+)\(((?:[^)(]+|\((?:[^)(]+|\([^)(]*\))*\))*)\)');
final argsPattern = RegExp(r'(\w+)=(\[[^\]]+\]|\([^\)]+\)|[^,]+)');

/// Takes in a string that is basically a python function call with named arguments
/// and converts it into a list of maps with the function name and arguments.
/// The list handles each function call in the string in order.
class FunctionParser {
  // Parse a single or multiline function call string
  List<Map<String, dynamic>> parseFunctionCalls(String input) {
    var functions = <Map<String, dynamic>>[];
    // First, split the string into lines
    var lines = input.split('\n');
    for (final line in lines) {
      // Then, assume each line is a single function call (that might have nested function calls).
      // Also assume that each function call has named arguments. Also, each
      // argument might be a nested function call.
      // Each argument consist of five possibilities:
      // - a string input denoted with single quotes (e.g., 'Oslo')
      // - a number (e.g., 1)
      // - a function name with parantheses, recursively using the same function
      // - a list of values (e.g., [1, 2, 3])
      // - a tuple of values (e.g., (1.1, 2.2))

      // First, generate a regEx that finds the function name and groups each argument consolidated with = between them. Comma if there are multiple arguments

      for (final match in functionAndArgumentsRegex.allMatches(line)) {
        final functionName = match.group(1)!;
        final argumentValue = match.group(2)!;
        final arguments = _parseArguments(argumentValue);
        functions.add({'function': functionName, 'arguments': arguments});
      }
    }

    return functions;
  }

  // Parse arguments of a function
  dynamic _parseArguments(String argsString) {
    var argsMap = <String, dynamic>{};

    // Split the argument string into matching key-values
    final argsMatches = argsPattern.allMatches(argsString);
    for (var match in argsMatches) {
      final key = match.group(1)!;
      final value = match.group(2)!;

      // Finds any nested functions
      final nestedFunctionMatches = functionAndArgumentsRegex.allMatches(match.group(0)!);

      if (value.startsWith('[') && value.endsWith(']')) {
        argsMap[key] = value.substring(1, value.length - 1).split(',').map((e) => double.tryParse(e.trim()) ?? e).toList();
      } else if (value.startsWith('(') && value.endsWith(')')) {
        argsMap[key] = value.substring(1, value.length - 1).split(',').map((e) => double.parse(e.trim())).toList();
      } else if (value.startsWith("'")) {
        argsMap[key] = value.substring(1, value.length - 1);
      } else if (double.tryParse(value) != null) {
        argsMap[key] = double.parse(value);
      } else if (nestedFunctionMatches.isNotEmpty) {
        for (final functionMatch in nestedFunctionMatches) {
          final arguments = _parseArguments(functionMatch.group(2)!);
          argsMap[key] = {'function': functionMatch.group(1), 'arguments': arguments};
        }
      }
    }
    if (argsMap.isEmpty) {
      return [];
    }
    return [argsMap];
  }
}
