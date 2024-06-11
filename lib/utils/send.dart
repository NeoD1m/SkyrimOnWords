import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> generateText(String input) async {
  const String url = 'https://nat.dev/api/inference/text';

  final Map<String, dynamic> data = {
    "prompt": input,
    "models": [
      {
        "name": "openai:gpt-4o",
        "tag": "openai:gpt-4o",
        "capabilities": ["chat"],
        "provider": "openai",
        "parameters": {
          "temperature": 0.6,
          "contextLength": 127999,
          "maximumLength": 2048,
          "topP": 1,
          "presencePenalty": 0,
          "frequencyPenalty": 0,
          "stopSequences": [],
          "numberOfSamples": 1
        },
        "enabled": true,
        "selected": true
      }
    ],
    "stream": true
  };
  final http.StreamedResponse response = await http.Client().send(
    http.Request('POST', Uri.parse(url))
      //..headers.addAll(headers)
      ..body = jsonEncode(data),
  );

  if (response.statusCode == 200) {
    return await processEventStream(response);
  } else {
    print('Request failed with status code ${response.statusCode}');
    return "";
  }
}

Future<String> processEventStream(http.StreamedResponse response) async {
  String result = "";
  String buffer = "";

  await for (var line in response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (line.isNotEmpty) {
      if (line.startsWith("data:")) {
        final String data = line.substring(5).trim();
        final Map<String, dynamic> jsonData = jsonDecode(data);
        final String token = jsonData["token"] ?? "";
        buffer += token;
        result += token;
      }
    }
  }

  result = result
      .replaceAll("[INITIALIZING]", "")
      .replaceAll("[COMPLETED]", "")
      .replaceAll("`", "")
      .replaceAll("json", "");
  return result;
}
