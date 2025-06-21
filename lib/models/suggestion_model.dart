// lib/models/suggestion_model.dart

class Place {
  final String name;
  final String category;
  final String icon;
  final String description;
  final List<String> suitableWeather;

  Place({
    required this.name,
    required this.category,
    required this.icon,
    required this.description,
    required this.suitableWeather,
  });

  // Factory para criar um Place a partir de um JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    // Pega o valor de 'suitable_weather' do JSON
    final weatherData = json['suitable_weather'];

    return Place(
      name: json['name'] ?? 'Nome indisponível', // Proteção extra
      category: json['category'] ?? 'Sem categoria', // Proteção extra
      icon: json['icon'] ?? 'location_on', // Proteção extra
      description: json['description'] ?? '', // Proteção extra
      // --- INÍCIO DA CORREÇÃO PRINCIPAL ---
      // Verifica se 'weatherData' é uma lista.
      // Se for, cria a lista de Strings. Se for nulo ou outra coisa, cria uma lista vazia [].
      suitableWeather: weatherData is List
          ? List<String>.from(weatherData)
          : [],
      // --- FIM DA CORREÇÃO PRINCIPAL ---
    );
  }
}
