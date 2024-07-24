import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp3/const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  String cityName = "Karachi";
  TextEditingController city = TextEditingController();

  Weather? _weather;
  List<Weather> _forecast = [];

  @override
  void initState() {
    super.initState();
    city.text = cityName;
    _fetchWeather(cityName);
    _fetchForcast(cityName);
  }

  void _fetchWeather(String name) {
    print("Fetching weather for $name");
    _wf.currentWeatherByCityName(name).then((w) {
      setState(() {
        _weather = w;
        print("Weather fetched successfully: ${_weather?.areaName}");
      });
    }).catchError((error) {
      print("Error fetching weather: $error");
      setState(() {
        _weather = null;
      });
    });
  }

  void _fetchForcast(String name) {
    print("Fetching forecast for $name");

    _wf.fiveDayForecastByCityName(name).then((w) {
      // Filter out only unique days and limit the result to 5 days
      final uniqueDays =
          <String, Weather>{}; // Using a map to store unique days

      for (var day in w) {
        // Format date to remove time part and keep only unique dates
        String dateKey = DateFormat('yyyy-MM-dd').format(day.date!);
        if (!uniqueDays.containsKey(dateKey)) {
          uniqueDays[dateKey] = day;
          if (uniqueDays.length == 5) {
            break; // Stop if we have 5 unique days
          }
        }
      }

      setState(() {
        _forecast = uniqueDays.values.toList();
        print(
            "Forecast fetched successfully. Number of days: ${_forecast.length}");

        _forecast.forEach((day) {
          print(
              "Date: ${day.date}, Description: ${day.weatherDescription}, Temp: ${day.temperature?.celsius}");
        });
      });
    }).catchError((error) {
      print("Error fetching forecast: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Weather App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _searchField(),
          SizedBox(height: 20.0),
          Expanded(
            child: _weather == null
                ? const Center(child: CircularProgressIndicator())
                : _weatherInfo(),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Stack(alignment: Alignment.centerRight, children: [
      TextField(
          controller: city,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Enter Name",
              hintText: "Enter City Name",
              suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _fetchForcast(cityName);
                    _fetchWeather(cityName);
                  })),
          onChanged: (value) {
            setState(() {
              cityName = value;
            });
          }),
    ]);
  }

  Widget _weatherInfo() {
    return ListView(
      children: [
        _areaName(),
        SizedBox(height: 20.0),
        _dateTimeInfo(),
        SizedBox(height: 20.0),
        _weatherIcon(),
        SizedBox(height: 20.0),
        _currentTemp(),
        SizedBox(height: 20.0),
        _extaInfo(),
        SizedBox(height: 20.0),
        _fiveDays(),
      ],
    );
  }

  Widget _areaName() {
    return Center(
      child: Text(
        _weather?.areaName ?? "No Data",
        style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather?.date ?? DateTime.now();
    return Column(
      children: [
        Text(
          DateFormat('h:mm a').format(now),
          style: const TextStyle(fontSize: 35),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEEE').format(now),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              " ${DateFormat('d.M.y').format(now)}",
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png",
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            _weather?.weatherDescription ?? "No Data",
            style: const TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Center(
      child: Text(
        "${_weather?.temperature?.celsius?.toStringAsFixed(0) ?? "N/A"} °C",
        style: TextStyle(
          fontSize: 90,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _extaInfo() {
    return Container(
      width: MediaQuery.sizeOf(context).height * 0.8,
      height: MediaQuery.sizeOf(context).height * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.deepPurple,
      ),
      padding: EdgeInsets.only(top: 8.0, bottom: 0.01),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0) ?? "N/A"} °C",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0) ?? "N/A"} °C",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0) ?? "N/A"}%",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              Text(
                "Wind Speed: ${_weather?.windSpeed?.toStringAsFixed(0) ?? "N/A"} m/s",
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fiveDays() {
    if (_forecast.isEmpty) {
      return Center(child: Text("No forecast data available"));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Next five days",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.0),
        SizedBox(
          height: 200.0,
          child: ListView.builder(
            itemCount: _forecast.length,
            itemBuilder: (context, index) {
              var day = _forecast[index];
              // Ensure day.date is not null
              DateTime date = day.date ?? DateTime.now();
              return ListTile(
                title: Text(
                  DateFormat('EEEE').format(date),
                  style: TextStyle(fontSize: 18.0),
                ),
                subtitle: Text(
                  "${day.weatherDescription ?? "No Description"}, ${day.temperature?.celsius?.toStringAsFixed(0) ?? "N/A"} °C",
                  style: TextStyle(fontSize: 16.0),
                ),
                leading: day.weatherIcon != null
                    ? Image.network(
                        "https://openweathermap.org/img/wn/${day.weatherIcon}@2x.png",
                      )
                    : SizedBox(width: 40, height: 40), // Placeholder if no icon
              );
            },
          ),
        ),
      ],
    );
  }
}
