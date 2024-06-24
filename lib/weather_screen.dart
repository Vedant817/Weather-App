import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/secrets.dart';

import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final result = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'));
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw data['message'];
      }
      // setState(() { /// Same as useState of React
      //   data['list'][0]['main']['temp'];
      // });
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            //? Used Gesture Detector but used Inkwell because it gives flash effect.
            onPressed: () {
              if (kDebugMode) {
                print("Refresh");
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FutureBuilder(
              future: getCurrentWeather(),
              builder: (context, snapshot) {
                // print(snapshot);
                // print(snapshot.runtimeType);
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if(snapshot.hasError){
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                final data = snapshot.data!;
                final currentTemp = data['list'][0]['main']['temp'];
                final currentSky = data['list'][0]['weather'][0]['main'];
                final currentPressure = data['list'][0]['main']['pressure'];
                final currentWindSpeed = data['list'][0]['wind']['speed'];
                final currentHumidity = data['list'][0]['main']['humidity'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '$currentTemp K',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Icon(
                                    currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.sunny,
                                    size: 64
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$currentSky',
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hourly Forecast',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       for(int i=0; i < 5; i++){
                      //         HourlyForecastItem(time: '00:00', temperature: '301.22', icon: Icons.cloud),
                      //       }
                      //     ],
                      //   ),
                      // ),
                      /// The above code may affect the performance of the app which is not good
                      SizedBox(
                        height: 120,
                        child: ListView.builder( /// ListView Builder has default height of full screen which should not be given, so wrapping it with the SizedBox
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index){
                            final hourlyForecast = data['list'][index + 1];
                            final hourlySky = data['list'][index + 1]['weather'][0]['main'];
                            final time = DateTime.parse(hourlyForecast['dt_text']);
                            return HourlyForecastItem(
                                time: DateFormat.j.format(time),
                                temperature: hourlyForecast['main']['temp'].toString(),
                                icon: hourlySky == 'Clouds' || hourlySky == 'Rain' ? Icons.cloud : Icons.sunny,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInformation(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: currentHumidity.toString()),
                          AdditionalInformation(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: currentWindSpeed.toString()),
                          AdditionalInformation(
                              icon: Icons.beach_access,
                              label: 'Pressure',
                              value: currentPressure.toString()),
                        ],
                      )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
