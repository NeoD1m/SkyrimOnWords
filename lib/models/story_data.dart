import 'dart:convert';
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

Future<StoryData> generateStoryData(String prompt,Function updatePrompt,Function getPrevStoryData,Function updatePrevPrompt) async {
  String text = await generateText(prompt);
  print(text);
  if (!isValidJson(text)){
    return getPrevStoryData();
  } else {
    updatePrompt(text);
    StoryData storyData = StoryData.fromJson(jsonDecode(text));
    updatePrevPrompt(storyData);
    return storyData;
  }
}

bool isValidJson(String text) {
  try {
    json.decode(text);
  } catch (e) {
    return false;
  }
  return true;
}