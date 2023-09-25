import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'model.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  bool isError = false;

  CurrentWeather? currentWeather;
  Daily? dailyData;

  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  Future<void> fetchDataFromApi() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&current_weather=true&timezone=auto',
        ),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        currentWeather =
            CurrentWeather.fromJson(decodedData['current_weather']);
        dailyData = Daily.fromJson(decodedData['daily']);

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather App'),
          backgroundColor: const Color.fromARGB(255, 247, 248, 252),
          titleTextStyle: const TextStyle(color: Colors.black),
          actions: const [Icon(Icons.menu)],
        ),
        body: WeatherScreen(
          currentWeather: currentWeather,
          dailyData: dailyData,
          fetchData: fetchDataFromApi,
          isLoading: isLoading,
          isError: isError,
          latitudeController: latitudeController,
          longitudeController: longitudeController,
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final CurrentWeather? currentWeather;
  final Daily? dailyData;
  final Function fetchData;
  final bool isLoading;
  final bool isError;

  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  const WeatherScreen({
    Key? key,
    this.currentWeather,
    this.dailyData,
    required this.fetchData,
    required this.isLoading,
    required this.isError,
    required this.latitudeController,
    required this.longitudeController,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 106, 168, 187),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: widget.latitudeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                hintText: 'enter latitude',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextField(
                              controller: widget.longitudeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                hintText: 'enter longitude',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 120.0,
                          )
                        ],
                      ),
                      Center(
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/cloudy.gif'), // Replace with the actual asset path
                              fit: BoxFit
                                  .cover, // You can use BoxFit to control how the image fits within the Container
                            ),
                          ),
                          height: 150.0, // Adjust the height as needed
                          width: 400.0,
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.wb_sunny, // "sunset" icon (you can change this)
                          size: 30.0,
                          color: Colors.orange, // Adjust the color as needed
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final double latitude =
                              double.tryParse(widget.latitudeController.text) ??
                                  0.0;
                          final double longitude = double.tryParse(
                                  widget.longitudeController.text) ??
                              0.0;

                          await widget.fetchData();
                        },
                        child: const Text('Get Weather'),
                      ),
                      const SizedBox(height: 1.0),
                      const SizedBox(height: 1.0),
                      const SizedBox(
                        height: 10.0,
                      ),
                      if (widget.isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (widget.isError)
                        const Text('error fetching data.')
                      else if (widget.currentWeather != null &&
                          widget.dailyData != null)
                       Expanded(
  child: Wrap(
    alignment: WrapAlignment.spaceEvenly,
    children: List.generate(
      widget.dailyData?.time?.length ?? 0,
      (index) {
        final forecastTime = widget.dailyData?.time?[index];
        final dateTime = DateTime.parse(forecastTime!);
        final formattedDate = DateFormat('EEEE').format(dateTime);

        final maxTemp = widget.dailyData?.temperature2mMax?[index];
        final minTemp = widget.dailyData?.temperature2mMin?[index];
        final windspeed = widget.dailyData?.uvIndexMax?[index];
        final weathercode = widget.dailyData?.uvIndexMax?[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Day: $formattedDate'),
                Text('Temperature: ${(maxTemp! + minTemp!) / 2.0}°C'),
                Text('Weather Code: $weathercode'),
                Text('Windspeed: $windspeed'),
              ],
            ),
          ),
        );
      },
    ),
  ),
)
             ]
             
             
                )
            )
  
        )
    );
  }
}
