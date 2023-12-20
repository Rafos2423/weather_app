import 'package:flutter/material.dart';
import 'package:weather_app/requests.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

void main() => runApp(const HomePage());

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => NameState();
}

class NameState extends State<HomePage> {
  TextEditingController place = new TextEditingController();
  String temperature = "";
  String weatherType = "";
  String dayTime = takeNameOfDayTime();
  List<WeatherData> weatherDataDays = List.empty();
  List<WeatherData> weatherDataHours = List.empty();

  @override
  void initState() {
    super.initState();
    _getLocation().then((placeInput) {
      fetchWeatherData(placeInput).then((result) => setState(() {
            temperature = result.$1;
            weatherType = result.$2;
            place.text = result.$3;
          }));
      fetchWeatherDataDay(placeInput).then((result) => setState(() {
            weatherDataDays = result;
          }));
      fetchWeatherHours(placeInput).then((result) => setState(() {
            weatherDataHours = result;
          }));
      checkInternetConnection();
    });
  }

  Future<void> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showInternetDialog();
    }
  }

  void _showInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Отсутствует подключение к интернету'),
          content: Text(
              'Пожалуйста, подключитесь к интернету, чтобы продолжить использование приложения.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _getLocation() async {
    LocationPermission _ = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks[0].locality.toString();
  }

  Widget buildWeatherInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 380,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          controller: place,
                          onSubmitted: (value) {
                            String modifiedString = value
                                .replaceAll(RegExp(r'[^\w\sа-яёА-ЯЁ]'), '')
                                .replaceAll(RegExp(r'\s+'), '');
                            fetchWeatherData(modifiedString)
                                .then((result) => setState(() {
                                      temperature = result.$1;
                                      weatherType = result.$2;
                                      place.text = result.$3;
                                    }));
                            fetchWeatherDataDay(modifiedString)
                                .then((result) => setState(() {
                                      weatherDataDays = result;
                                    }));
                          },
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: place.text),
                            );
                            place.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: place.text.length,
                            );
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ваш город:',
                            hintStyle: TextStyle(color: Colors.white),
                            counterText: "",
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLength: 14,
                        ),
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Text(
                          "$temperature°",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 30),
                        Flexible(
                          child: Center(
                            child: Text(
                              weatherType,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image(
                  image: AssetImage('assets/$dayTime.gif'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(12.0),
              ),
              width: 380,
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: weatherDataDays.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                padding: EdgeInsets.all(22),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      weatherDataDays[index].fullWeekDay,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image(
                                        image: AssetImage(
                                            'assets/${weatherDataDays[index].imageName}.jpg'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildWeatherInfo('Температура',
                                            '${weatherDataDays[index].temperature}°'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Ощущается как',
                                            '${weatherDataDays[index].feelsLike}°'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Скорость ветра',
                                            '${weatherDataDays[index].windSpeed}м/c'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Влажность',
                                            '${weatherDataDays[index].humidity}%'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Давление',
                                            '${weatherDataDays[index].pressure}мм.'),
                                        SizedBox(height: 5),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 105,
                              child: Text(
                                weatherDataDays[index].weekDay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              width: 200,
                              child: Text(
                                weatherDataDays[index].description,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            Container(
                              width: 40,
                              child: Text(
                                "${weatherDataDays[index].temperature}°",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(12.0),
              ),
              width: 380,
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weatherDataHours.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Container(
                                padding: EdgeInsets.all(22),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      weatherDataHours[index].time,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: Image(
                                        image: AssetImage(
                                            'assets/${weatherDataHours[index].imageName}.jpg'),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        buildWeatherInfo('Температура',
                                            '${weatherDataHours[index].temperature}°'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Ощущается как',
                                            '${weatherDataHours[index].feelsLike}°'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Скорость ветра',
                                            '${weatherDataHours[index].windSpeed}м/c'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Влажность',
                                            '${weatherDataHours[index].humidity}%'),
                                        SizedBox(height: 10),
                                        buildWeatherInfo('Давление',
                                            '${weatherDataHours[index].pressure}мм.'),
                                        SizedBox(height: 5),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 180,
                            child: Column(
                              children: [
                                Text(
                                  weatherDataHours[index].time,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Divider(
                                  height: 0,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "${weatherDataHours[index].description}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "${weatherDataHours[index].temperature}°",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                        ],
                      ));
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
