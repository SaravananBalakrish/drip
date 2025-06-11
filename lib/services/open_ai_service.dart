import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  // final String _apiKey = "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"; // Replace with secure storage in production
  final String _apiKey = "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"; // Replace with secure storage in production

  Future<String?> getChatResponse(String userMessage) async {
    const endpoint = "https://api.openai.com/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          // "model": "gpt-4o-mini",
          'model': "gpt-4.1",
          "messages": [
            {"role": "user", "content": userMessage}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        return reply;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown API error';
        print('errorMessage :: $errorMessage');
        return Future.error('API Error: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('error :: $e');
      return Future.error('Network Error: $e');
    }
  }
}

class GrokAIService {
  // final String _apiKey = "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"; // Replace with secure storage in production
  final String _apiKey = "xai-8OzD8MJ5gROsZoOHJtttxOye2Jftej6AFVc8zsvKGxsB7wjmgC4j4h6ek8jp1NitwSTZGpciiY3KaoK5"; // Grok ai

  Future<String?> getChatResponse(String userMessage) async {
    const endpoint = "https://api.x.ai/v1/chat/completions";

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          // "model": "gpt-4o-mini",
          'model': "gpt-4.1",
          "messages": [
            {"role": "user", "content": userMessage}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        return reply;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown API error';
        print('errorMessage :: $errorMessage');
        return Future.error('API Error: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('error :: $e');
      return Future.error('Network Error: $e');
    }
  }
}