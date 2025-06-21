// lib/services/suggestion_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/suggestion_model.dart';
import '../models/weather_model.dart';

class SuggestionService {
  // Guarde sua chave de API de forma segura (ex: usando flutter_dotenv)
  static const String GEMINI_API_KEY =
      "AIzaSyDHtYHYXeYUGn-Ks6lPvjfkYiOt9WuOZsc"; // Lembre-se de usar sua chave
  static const String API_URL =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY";

  Future<List<Place>> getSuggestionsForWeather(Weather weather) async {
    String prompt =
        """
      Você é um assistente de guia turístico local. Sua tarefa é fornecer sugestões de atividades com base em uma cidade e nas condições climáticas fornecidas.
      Responda APENAS com um objeto JSON válido, sem nenhum texto, explicação ou formatação extra antes ou depois do JSON.
      A cidade atual é ${weather.cityName} e o clima é ${weather.mainCondition} com temperatura de ${weather.temperature.round()}°C.
      Forneça 4 sugestões de atividades. Para atividades ao ar livre, só as sugira se o tempo estiver bom (sem chuva ou frio extremo).
      O JSON deve seguir esta estrutura:
      {
        "suggestions": [
          {
            "name": "Nome do Local ou Atividade",
            "category": "Tipo de Categoria (ex: Ao Ar Livre, Comida, Cultura)",
            "icon": "location_on",
            "description": "Uma descrição curta e atrativa (máximo 15 palavras)."
          }
        ]
      }
    """;

    try {
      final response = await http.post(
        Uri.parse(API_URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final rawText =
            responseBody['candidates'][0]['content']['parts'][0]['text']
                as String;

        final startIndex = rawText.indexOf('{');
        final endIndex = rawText.lastIndexOf('}');

        if (startIndex == -1 || endIndex == -1) {
          // Se não encontrou um JSON na resposta, avisa e retorna lista vazia.
          print("Nenhum JSON válido encontrado na resposta da IA.");
          return [];
        }

        // Extrai a substring que contém o JSON válido
        final jsonString = rawText.substring(startIndex, endIndex + 1);
        final suggestionsJson = jsonDecode(jsonString);

        if (suggestionsJson is Map &&
            suggestionsJson.containsKey('suggestions') &&
            suggestionsJson['suggestions'] is List) {
          List<dynamic> placesData = suggestionsJson['suggestions'];
          return placesData
              .map((p) => Place.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          // Se o JSON era válido mas a estrutura estava errada, avisa e retorna lista vazia.
          print("Estrutura do JSON da IA inesperada: $jsonString");
          return [];
        }
      } else {
        // Se a API retornou um erro (status code != 200)
        print("Erro na API do Gemini: ${response.body}");
        return [];
      }
    } catch (e) {
      // Se qualquer outra coisa der errado (falha de rede, etc.)
      print("Erro ao chamar o serviço de sugestões: $e");
      return [];
    }
  }
}
