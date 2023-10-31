import 'dart:convert';
import 'package:http/http.dart' as http;

Future<(String temp, String weather)> fetchWeatherData() async {
  String apiKey = 'b0451ff37db30a84fd165a651194a814';
  String cityName = 'Moscow';
  String units = 'metric'; // ед измерения - градусы
  String cnt = '1'; // кол результатов (вывод 4 города Москвы без явного указания)
  String language = 'ru';

  final Uri uri = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
    'q': cityName,
    'units': units,
    'appid': apiKey,
    'cnt': cnt,
    'lang': language,
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final dynamic temperature = data['main']['temp'];
    String weather = data['weather'][0]['description'];

    weather = "${weather[0].toUpperCase()}${weather.substring(1)}";
    return (temperature.toInt().toString(), weather);
  } else {
    throw Exception('Failed to fetch weather data: ${response.reasonPhrase}');
  }
}

String takeNameOfDayTime() {
  DateTime now = DateTime.now().toUtc();

  if (now.hour >= 0 && now.hour < 6) {
    return 'night';
  } else if (now.hour >= 6 && now.hour < 12) {
    return 'morning';
  } else if (now.hour >= 12 && now.hour < 18) {
    return 'day';
  } else if (now.hour >= 18 && now.hour < 24) {
    return 'evening';
  } else {
    return 'day';
  }
}

Future<List<WeatherData>> fetchWeatherDataDay() async {
  String apiKey = 'b0451ff37db30a84fd165a651194a814';
  String cityName = 'Moscow';
  String units = 'metric'; // ед измерения - градусы
  String language = 'ru';

  final Uri uri = Uri.https('api.openweathermap.org', 'data/2.5/forecast', {
    'q': cityName,
    'units': units,
    'appid': apiKey,
    'lang': language,
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonData = jsonDecode(response.body);

    List<dynamic> forecastData = jsonData['list'];
    List<WeatherData> weatherDataList = [];

    for (var i = 0; i < 5; i++) {
      Map<String, dynamic> forecast = forecastData[i * 8];
      String weekDay =
          DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000)
              .toUtc()
              .weekday
              .toString();

      List<String> weekDays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];

      String dayName = "";
      if (i == 0)
        dayName = "Сегодня";
      else if (i == 1)
        dayName = "Завтра";
      else
        dayName = weekDays[int.parse(weekDay) - 1];

      String weather = forecast['weather'][0]['description'];
      weather = "${weather[0].toUpperCase()}${weather.substring(1)}";

      String temp = forecast['main']['temp'].toInt().toString();

      WeatherData weatherData = WeatherData(dayName, weather, temp);

      weatherDataList.add(weatherData);
    }

    return weatherDataList;
  } else {
    throw Exception('Failed to fetch weather data');
  }
}

class WeatherData {
  final String weekDay;
  final String description;
  final String temperature;

  WeatherData(this.weekDay, this.description, this.temperature);
}
