class ClientResult {
  ClientResult({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.system_fingerprint,
    required this.choices,
    required this.usage,
  });

  String id;
  String object;
  int created;
  String model;
  String system_fingerprint;
  List<Choice> choices;
  Usage usage;

  factory ClientResult.fromJson(Map<String, dynamic> json) {
    return ClientResult(
      id: json['id'],
      object: json['object'],
      created: json['created'],
      model: json['model'],
      system_fingerprint: json['system_fingerprint'],
      choices: List<Choice>.from(json['choices'].map((x) => Choice.fromJson(x))),
      usage: Usage.fromJson(json['usage']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'created': created,
      'model': model,
      'system_fingerprint': system_fingerprint,
      'choices': List<dynamic>.from(choices.map((x) => x.toJson())),
      'usage': usage.toJson(),
    };
  }
}

class Choice {
  Choice({
    required this.index,
    required this.message,
    required this.logprobs,
    required this.finish_reason,
  });

  int index;
  Message message;
  dynamic logprobs;
  String finish_reason;

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      index: json['index'],
      message: Message.fromJson(json['message']),
      logprobs: json['logprobs'],
      finish_reason: json['finish_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'message': message.toJson(),
      'logprobs': logprobs,
      'finish_reason': finish_reason,
    };
  }
}

class Message {
  Message({
    required this.role,
    required this.content,
  });

  String role;
  String content;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class Usage {
  Usage({
    required this.prompt_tokens,
    required this.completion_tokens,
    required this.total_tokens,
  });

  int prompt_tokens;
  int completion_tokens;
  int total_tokens;

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      prompt_tokens: json['prompt_tokens'],
      completion_tokens: json['completion_tokens'],
      total_tokens: json['total_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt_tokens': prompt_tokens,
      'completion_tokens': completion_tokens,
      'total_tokens': total_tokens,
    };
  }
}
  
/*

ChatGPT response
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-3.5-turbo-0613",
  "system_fingerprint": "fp_44709d6fcb",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "\n\nHello there, how may I assist you today?",
    },
    "logprobs": null,
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 9,
    "completion_tokens": 12,
    "total_tokens": 21
  }
}

Ollama response
{
  "model": "llama2",
  "created_at": "2023-08-04T19:22:45.499127Z",
  "response": "The sky is blue because it is the color of the sky.",
  "done": true,
  "context": [1, 2, 3],
  "total_duration": 5043500667,
  "load_duration": 5025959,
  "prompt_eval_count": 26,
  "prompt_eval_duration": 325953000,
  "eval_count": 290,
  "eval_duration": 4709213000
}

*/