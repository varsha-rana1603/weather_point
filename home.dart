import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_point/models/city.dart';
import 'package:weather_point/models/constants.dart';
import 'package:weather_point/ui/detail_page.dart';
import 'package:weather_point/widgets/weather_item.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Constants myConstants = Constants();

  //initialization
  int temp = 0;
  int temperature = 0;
  int maxTemp = 0;
  String weatherStateName = 'Loading...';
  int humidity = 0;
  int windSpeed = 0;

  //Create a shader linar gradient
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  String imageUrl = '';
  String location = 'New Delhi'; //default city

//get the cities and selected cities data
  var selectedCities = City.getSelectedCities();
  List<String> cities = [
    'New Delhi'
  ]; // the list to hold our selected cities, default is New Delhi

  List consolidatedWeatherList = []; //to hold weather data after API call

//API calls url
  String searchWeatherUrl =
      'https://api.openweathermap.org/data/2.5/weather?q=';


  void fetchWeatherData() async {
    var weatherResult = await http.get(Uri.parse(searchWeatherUrl + location + '&appid=$openWeatherAPIKey'));
    Map<String, dynamic> result = json.decode(weatherResult.body);
    dynamic weatherData = result['main'];
    dynamic wind = result['wind'];
    dynamic weatherState = result['weather'];

    setState(() {
      //consolidatedWeatherList.clear(); //Clear the list before adding new data

      //the index 0 refers to the first entry which is the current day.
       temp = weatherData['temp'].toInt();
       temperature = (temp - 273);
       humidity = weatherData['humidity'].toInt();
       windSpeed = wind['speed'].toInt();
       maxTemp = weatherData['temp_max'].toInt();
       weatherStateName = weatherState[0]['description'];

       print(weatherStateName);

    });
  }

  @override
  void initState() {
    fetchWeatherData();

    //For all the selected cities from the City model, extract the city and add it to the original cities list
    for (int i = 0; i < selectedCities.length; i++) {
      cities.add(selectedCities[i].city);
    }

    super.initState();
  }

    @override
    Widget build(BuildContext context) {
      Size size = MediaQuery.of(context).size;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //The profile image
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.asset(
                    'assets/profile.png',
                    width: 40,
                    height: 40,
                  ),
                ),

                //location dropdown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pin.png',
                      width: 20,
                    ),
                    const SizedBox(
                      width: 4,
                    ),

                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                          value: location,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: cities.map((String location) {
                            return DropdownMenuItem(
                                value: location, child: Text(location));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              location = newValue!;
                              fetchWeatherData();
                            });
                          }),
                    )
                  ],
                )
              ],
            ),
          ),
        ),

        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              const SizedBox(height: 10),
              const CurrentDate(),

              const SizedBox(
                height: 50,
              ),

              Container(
                width: size.width,
                height: 200,
                decoration: BoxDecoration(
                    color: myConstants.primaryColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: myConstants.primaryColor.withOpacity(.5),
                        offset: const Offset(0, 25),
                        blurRadius: 10,
                        spreadRadius: -12,
                      )
                    ]),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -40,
                      left: 20,
                      child: imageUrl == weatherStateName  ? const Text('haze') :
                      Image.asset(
                        imageUrl.isNotEmpty
                            ? 'assets/$imageUrl.png'  // Your dynamic asset
                            : 'assets/haze.png',  // Default asset
                        width: 150,
                      ),

                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: Text(
                        weatherStateName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              temperature.toString(),
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = linearGradient,
                              ),
                            ),
                          ),
                          Text(
                            'o',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    weatherItem(
                        text: 'Wind Speed',
                        value: windSpeed,
                        unit: 'km/h',
                        imageUrl: 'assets/windspeed.png'),
                    weatherItem(
                        text: 'Humidity',
                        value: humidity,
                        unit: '',
                        imageUrl: 'assets/humidity.png'),
                    weatherItem(
                        text: 'Temperature',
                        value: temperature,
                        unit: '°C',
                        imageUrl: 'assets/max-temp.png'),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
             const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                     'TODAY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: consolidatedWeatherList.length,
                      itemBuilder: (BuildContext context, int index) {
                        String today = DateTime.now().toString().substring(
                            0, 10);
                        var selectedDay = consolidatedWeatherList[index]['applicable_date'];
                        var futureWeatherName = consolidatedWeatherList[index]['weather_state_name'];
                        var weatherUrl = futureWeatherName.replaceAll(' ', '')
                            .toLowerCase();
                        var parsedDate = DateTime.parse(
                            consolidatedWeatherList[index]['applicable_date']);
                        var newDate = DateFormat('EEEE')
                            .format(parsedDate)
                            .substring(0, 3); //formatted date

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  consolidatedWeatherList: consolidatedWeatherList,
                                  selectedId: index,
                                  location: location,)));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            margin: const EdgeInsets.only(
                              right: 20,
                              bottom: 10,
                              top: 10,
                            ),
                            width: 80,
                            decoration: BoxDecoration(
                                color: selectedDay == Icons.today ? myConstants.primaryColor : Colors.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10)),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 5,
                                    color: selectedDay == today ? myConstants.primaryColor : Colors.black54.withOpacity(.2),
                                  ),
                                ]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  consolidatedWeatherList[index]['the_temp'].round().toString() + "C",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: selectedDay == today
                                        ? Colors.white
                                        : myConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Image.asset('assets/' + weatherUrl + '.png',
                                  width: 30,
                                ),
                                Text(newDate,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 17,
                                    color: selectedDay == today
                                        ? Colors.white
                                        : myConstants.primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }))
            ],
          ),
        ),
      );
    }

  currentDate() {}
  }

  class CurrentDate extends StatefulWidget {
    const CurrentDate({super.key});

    @override
    _CurrentDateState createState() => _CurrentDateState();
  }

  class _CurrentDateState extends State<CurrentDate>{
  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); //get the current date
    String currentDate = DateFormat('EEEE, MMMM d, y').format(now) ;

      //return a widget
    return Text(
      '$currentDate',
      style: TextStyle(
        fontSize: 12,
      ),
    );
    }
  }

