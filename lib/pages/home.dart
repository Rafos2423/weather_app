import 'package:flutter/material.dart';
import 'package:weather_app/requests.dart';

void main() => runApp(const HomePage());

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => NameState();
}

class NameState extends State<HomePage> {
  String temperature = "";
  String weatherType = "";
  String dayTime = takeNameOfDayTime();
  List<WeatherData> weatherData = List.empty();

  @override
  void initState() {
    super.initState();
    fetchWeatherData().then((result) => setState(() {
          temperature = result.$1;
          weatherType = result.$2;
        }));
    fetchWeatherDataDay().then((result) => setState(() {
          weatherData = result;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          const SizedBox(height: 90),
          Center(
            child: Container(
              width: 380,
              height: 185,
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
                      Text(
                        'Москва',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Text(
                          "$temperature°",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 80,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 40),
                        Flexible(
                          child: Center(
                            child: Text(
                              weatherType,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
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
          const SizedBox(height: 30),
          Center(
            child: Container(
              width: 220,
              height: 220,
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
          const SizedBox(height: 30),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(12.0),
              ),
              width: 380,
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: weatherData.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 80,
                    child: Row(
                      children: [
                        Container(
                          width: 105,
                          child: Text(
                            weatherData[index].weekDay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 175,
                          child: Flexible(
                            child: Text(
                              weatherData[index].description,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          child: Text(
                            "${weatherData[index].temperature}°",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}