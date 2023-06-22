import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

void main() {
  fetchWeatherData();
}

void fetchWeatherData() async {
  final apiKey = '1c9d0ad4a66d125917f3a738e44eef98';

  // Get the user's current location
  Position position;
  try {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  } catch (e) {
    print('Error getting location: $e');
    return;
  }

  final apiUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey');

  final response = await http.get(apiUrl);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    final temperature = jsonData['main']['temp'];
    final humidity = jsonData['main']['humidity'];
    final windSpeed = jsonData['wind']['speed'];
    final weatherDescription = jsonData['weather'][0]['description'];

    print('Temperature: $temperature');
    print('Humidity: $humidity');
    print('Wind Speed: $windSpeed');
    print('Weather Description: $weatherDescription');
  } else {
    print('Error: ${response.statusCode}');
  }
}
