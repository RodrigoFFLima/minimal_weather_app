import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../models/suggestion_model.dart';
import '../models/weather_model.dart';
import '../services/suggestion_service.dart';
import '../services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Serviços para buscar dados da API
  final _weatherService = WeatherService(
    '6678b2d89defed2c1370fcee645b2c96',
  ); // Coloque sua chave da OpenWeather
  final _suggestionService = SuggestionService();

  // Variáveis de estado para guardar os dados e controlar o carregamento
  Weather? _weather;
  List<Place> _suggestions = [];
  bool _isLoading = true; // Loading principal da página
  bool _isLoadingSuggestions = false; // Loading específico para as sugestões

  @override
  void initState() {
    super.initState();
    // Busca os dados assim que a página é iniciada
    _fetchWeatherAndSuggestions();
  }

  // Função principal que orquestra a busca de dados
  _fetchWeatherAndSuggestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. OBTER A CIDADE
      // Para testar, você pode forçar uma cidade aqui:
      final String cityName = "Berlim";
      //final String cityName = await _weatherService.getCurrentCity();

      // 2. OBTER O CLIMA
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _isLoading = false; // Clima carregado, loading principal pode sumir
        _isLoadingSuggestions = true; // Começa a carregar as sugestões
      });

      // 3. OBTER AS SUGESTÕES
      final suggestions = await _suggestionService.getSuggestionsForWeather(
        weather,
      );
      setState(() {
        _suggestions = suggestions;
        _isLoadingSuggestions = false; // Sugestões carregadas
      });
    } catch (e) {
      print(e);
      // Garante que os loadings parem mesmo se der erro
      setState(() {
        _isLoading = false;
        _isLoadingSuggestions = false;
      });
    }
  }

  // Função auxiliar para escolher a animação Lottie
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json'; // Padrão

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // Função auxiliar para escolher o ícone com base na categoria
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ao ar livre':
        return Icons.park_outlined;
      case 'cultura':
        return Icons.museum_outlined;
      case 'comida':
        return Icons.restaurant_outlined;
      case 'compras':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  // Em lib/pages/weather_page.dart
  // Substitua todo o seu método build() por este
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Um cinza bem claro
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : ListView(
                  // A Column foi trocada por uma ListView para que tudo role junto.
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    // NOME DA CIDADE
                    Text(
                      _weather?.cityName ?? "Carregando cidade...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // ANIMAÇÃO LOTTIE
                    //Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
                    SizedBox(
                      height:
                          200, // <<-- Você pode ajustar este valor como quiser!
                      child: Lottie.asset(
                        getWeatherAnimation(_weather?.mainCondition),
                      ),
                    ),
                    // TEMPERATURA
                    Text(
                      '${_weather?.temperature.round()}°C',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // CONDIÇÃO DO CLIMA
                    Text(
                      _weather?.mainCondition ?? "",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TÍTULO DA SEÇÃO DE SUGESTÕES
                    if (_suggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Sugestões para seu dia",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // INDICADOR DE LOADING PARA SUGESTÕES
                    if (_isLoadingSuggestions)
                      const Center(child: CircularProgressIndicator())
                    else
                      // CONSTRUÇÃO DINÂMICA DOS CARDS
                      // Usamos .map para transformar cada 'place' em um widget Card
                      // e o operador '...' (spread) para inserir todos na ListView.
                      ..._suggestions.map((place) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 1,
                          color: Colors.white,
                          child: ExpansionTile(
                            leading: Icon(
                              _getIconForCategory(place.category),
                              color: Colors.black87,
                            ),
                            title: Text(
                              place.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            iconColor: Colors.black54,
                            collapsedIconColor: Colors.black54,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Text(
                                  place.description,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
        ),
      ),
    );
  }
}
