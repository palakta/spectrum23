import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit,
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentTemperature = '';
  String currentHumidity = '';
  String currentWindSpeed = '';
  String currentWeatherDescription = '';
  String searchQuery = '';
  List<WeatherForecast> forecastData = [];
  bool isLoading = false;
  TemperatureUnit temperatureUnit = TemperatureUnit.celsius;

  @override
  void initState() {
    super.initState();
    fetchCurrentWeatherData();
    fetchForecastData();
  }

  void fetchCurrentWeatherData() async {
    final apiKey = '1c9d0ad4a66d125917f3a738e44eef98';

    setState(() {
      isLoading = true;
    });

    // Get the current location
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      print('Error getting current location: $e');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final apiUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      setState(() {
        final temperatureInKelvin = jsonData['main']['temp'];
        currentTemperature = convertTemperature(temperatureInKelvin);
        currentHumidity = jsonData['main']['humidity'].toString();
        currentWindSpeed = jsonData['wind']['speed'].toString();
        currentWeatherDescription = jsonData['weather'][0]['description'];
        isLoading = false;
      });
    } else {
      print('Error: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchForecastData() async {
    final apiKey = '1c9d0ad4a66d125917f3a738e44eef98';

    if (searchQuery.isEmpty) {
      return;
    }

    final apiUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$searchQuery&appid=$apiKey');

    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      List<WeatherForecast> forecasts = [];

      for (var item in jsonData['list']) {
        final dateTime = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final temperatureInKelvin = item['main']['temp'];
        final temperature = convertTemperature(temperatureInKelvin);
        final weatherDescription = item['weather'][0]['description'];

        forecasts.add(
          WeatherForecast(
            dateTime: dateTime,
            temperature: temperature,
            weatherDescription: weatherDescription,
          ),
        );
      }

      setState(() {
        forecastData = forecasts;
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  String convertTemperature(double temperatureInKelvin) {
    if (temperatureUnit == TemperatureUnit.celsius) {
      final temperatureInCelsius = temperatureInKelvin - 273.15;
      return temperatureInCelsius.toStringAsFixed(1) + ' °C';
    } else {
      final temperatureInFahrenheit = (temperatureInKelvin * 9 / 5) - 459.67;
      return temperatureInFahrenheit.toStringAsFixed(1) + ' °F';
    }
  }

  void toggleTemperatureUnit() {
    setState(() {
      if (temperatureUnit == TemperatureUnit.celsius) {
        temperatureUnit = TemperatureUnit.fahrenheit;
      } else {
        temperatureUnit = TemperatureUnit.celsius;
      }
    });
  }

  void searchWeatherData() {
    fetchForecastData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: searchWeatherData,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Current Weather',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Temperature:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currentTemperature,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Humidity:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(currentHumidity),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Wind Speed:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(currentWindSpeed),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Weather Description:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(currentWeatherDescription),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      '5-Day Forecast',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: forecastData.length,
                        itemBuilder: (context, index) {
                          final forecast = forecastData[index];
                          return Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    forecast.dateTime.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text('Temperature: ${forecast.temperature}'),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Weather Description: ${forecast.weatherDescription}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Temperature Unit:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: toggleTemperatureUnit,
                          child: Text(
                            temperatureUnit == TemperatureUnit.celsius
                                ? 'Celsius'
                                : 'Fahrenheit',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class WeatherForecast {
  final DateTime dateTime;
  final String temperature;
  final String weatherDescription;

  WeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.weatherDescription,
  });
}
