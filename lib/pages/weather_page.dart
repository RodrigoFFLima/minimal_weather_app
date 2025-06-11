import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:minimal_weather_app/services/weather_service.dart';

import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //api key
  final _weatherService = WeatherService('6678b2d89defed2c1370fcee645b2c96');
  Weather? _weather;

  //insere o clima
  _fetchWeather() async {
    //pega a cidade atual
    String city = await _weatherService.getCurrentCity();
    try {
      //pega o clima da cidade
      Weather weather = await _weatherService.getWeather(city);
      setState(() {
        _weather = weather;
      });
    }
    //trata erros
    catch (e) {
      print('Error fetching weather: $e');
    }
  }

  //animações do clima
  String GetWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) {
      return 'assets/sunny.json';
    }

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
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  //status inicial
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Nome da cidade
            Text(
              _weather?.cityName ?? 'Loading...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            //Ícone do clima
            Lottie.asset(GetWeatherAnimation(_weather?.mainCondition)),
            //Temperatura
            Text(
              '${_weather?.temperature.round().toString()}ºC' ?? 'Loading...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            //Condição do clima
            Text(
              _weather?.mainCondition ?? 'Loading...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
