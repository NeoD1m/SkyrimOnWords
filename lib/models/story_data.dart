import 'dart:convert';
import 'package:NeoDim_Skyrim_on_Words/utils/gpt_runner.dart';

import '../main.dart';
import '../utils/send.dart';

class StoryData {
  final String image;
  final String text;
  final List<String> button;

  StoryData({
    required this.image,
    required this.text,
    required this.button,
  });

  factory StoryData.fromJson(Map<String, dynamic> json) {
    return StoryData(
      image: json['image'],
      text: json['text'],
      button: List<String>.from(json['button']),
    );
  }
}

Future<StoryData> generateStoryData(String prompt, Function updatePrompt,
    Function getPrevStoryData, Function updatePrevPrompt) async {
  //String text = await generateText(prompt);
  String text = await runExecutable(prompt);
  print(text);
  if (!isValidJson(text)) {
    text = validateJson(text);
    updatePrompt(text);
    StoryData storyData = StoryData.fromJson(jsonDecode(text));
    updatePrevPrompt(storyData);
    return storyData;
  } else {
    updatePrompt(text);
    StoryData storyData = StoryData.fromJson(jsonDecode(text));
    updatePrevPrompt(storyData);
    return storyData;
  }
}

String validateJson(String inputText) {
  // Define a regular expression to match the JSON object
  final jsonRegExp = RegExp(r'\{[^}]*\}');

  // Find the JSON part in the input text
  final match = jsonRegExp.firstMatch(inputText);

  if (match != null) {
    String jsonString = match.group(0)!;
    try {
      // Parse the JSON string to verify it is valid
      Map<String, dynamic> jsonObject = jsonDecode(jsonString);

      // Re-encode the JSON object to ensure it is formatted correctly
      String finalJsonString = jsonEncode(jsonObject);
      return finalJsonString;
    } catch (e) {
      // Handle JSON parsing error
      return jsonEncode({'error': 'Failed to parse JSON: $e'});
    }
  } else {
    // Handle case where no JSON is found
    return jsonEncode({'error': 'No JSON found in the input text.'});
  }
}

bool isValidJson(String text) {
  try {
    json.decode(text);
  } catch (e) {
    print(e);
    return false;
  }
  return true;
}
