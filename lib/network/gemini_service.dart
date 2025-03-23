import 'package:google_generative_ai/google_generative_ai.dart';


class GeminiService {
  static const String apiKey = "AIzaSyDinmu21AOYHC8NyHhIvWnoOgV_4BGkAGM";

  static Future<String> generateRecommendation(String genre, String language) async {
    final prompt = "Berikan rekomendasi 5 novel terbaik dalam genre $genre dengan bahasa $language. Sertakan judul, penulis, deskripsi singkat, dan alasan kenapa novel tersebut menarik.";

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat();
    final content = Content.text(prompt);

    try {
      final response = await chat.sendMessage(content);
      String responseText = (response.candidates.first.content.parts.first as TextPart).text;
      responseText = responseText.replaceAll('*', '').replaceAll('"', '');
      responseText = responseText.replaceAll(RegExp(r'^\d+\.\s*', multiLine: true), '');
      return responseText.isNotEmpty ? responseText : "Failed to generate recommendations.";
    } catch (e) {
      return "Failed to generate recommendations.";
    }
  }
}
