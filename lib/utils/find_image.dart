import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> fetchImageUrl(String searchQuery) async {
  final url = Uri.parse('https://duckduckgo.com/?q=${Uri.encodeQueryComponent(searchQuery)}&t=h_&iax=images&ia=images');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final body = response.body;
    final regex = RegExp(r'vqd=([\d-]+)&');
    final match = regex.firstMatch(body);

    if (match != null) {
      final vqd = match.group(1);
      final imageUrl = Uri.parse('https://duckduckgo.com/i.js?l=us-en&o=json&q=${Uri.encodeQueryComponent(searchQuery)}&vqd=$vqd');
      final imageResponse = await http.get(imageUrl);

      if (imageResponse.statusCode == 200) {
        final imageJson = json.decode(imageResponse.body);
        if (imageJson['results'] != null && imageJson['results'].isNotEmpty) {
          return imageJson['results'][0]['image'];
        }
      }
    }
  }

  throw Exception('Failed to fetch image URL');
}