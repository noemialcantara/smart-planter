import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/models/chart_data.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PlantLibraryDetailPage extends StatefulWidget {
  final String plantName;
  final String imageURL;
  const PlantLibraryDetailPage(
      {Key? key, required this.plantName, required this.imageURL})
      : super(key: key);

  @override
  State<PlantLibraryDetailPage> createState() => _PlantLibraryDetailPageState();
}

class _PlantLibraryDetailPageState extends State<PlantLibraryDetailPage> {
  //Toggle add remove from cart
  bool toggleIsSelected(bool isSelected) {
    return !isSelected;
  }

  final List<ChartData> lightChartData = [
    ChartData("Mon", 35, AppColors.lightSensorBarColor),
    ChartData("Tue", 28, AppColors.lightSensorBarColor),
    ChartData("Wed", 34, AppColors.lightSensorBarColor),
    ChartData("Thu", 32, AppColors.lightSensorBarColor),
    ChartData("Fri", 40, AppColors.lightSensorBarColor),
    ChartData("Sat", 35, AppColors.lightSensorBarColor),
    ChartData("Sun", 28, AppColors.lightSensorBarColor),
  ];

  final List<ChartData> waterChartData = [
    ChartData("Mon", 35, AppColors.waterMoistureSensorBarColor),
    ChartData("Tue", 28, AppColors.waterMoistureSensorBarColor),
    ChartData("Wed", 34, AppColors.waterMoistureSensorBarColor),
    ChartData("Thu", 32, AppColors.waterMoistureSensorBarColor),
    ChartData("Fri", 40, AppColors.waterMoistureSensorBarColor),
    ChartData("Sat", 35, AppColors.waterMoistureSensorBarColor),
    ChartData("Sun", 28, AppColors.waterMoistureSensorBarColor),
  ];

  final List<Color> waterColorVariation = [
    AppColors.waterMoistureSensorBarColor,
    Colors.blue[200]!,
    Colors.blue[50]!,
  ];

  final List<Color> lightColorVariation = [
    AppColors.lightSensorBarColor,
    Colors.orange[200]!,
    Colors.orange[50]!,
  ];

  final List<double> stops = [0, 0.5, 1];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final LinearGradient waterGradientColors = LinearGradient(
      colors: waterColorVariation,
      stops: stops,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final LinearGradient lightGradientColors = LinearGradient(
      colors: lightColorVariation,
      stops: stops,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      body: Container(
          color: AppColors.white,
          child: Stack(
            children: [
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: AppColors.primaryColor.withOpacity(.15),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Container(
                  width: size.width * .8,
                  height: size.height * .8,
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plantName,
                            style: GoogleFonts.openSans(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Scrollbar(
                    child: Container(
                        padding:
                            const EdgeInsets.only(top: 80, left: 30, right: 30),
                        height: size.height * .6,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30),
                            topLeft: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Ficus",
                                  style: GoogleFonts.openSans(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600),
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/solar_icon.png',
                                          fit: BoxFit.cover,
                                          height: 25,
                                          width: 25,
                                        ),
                                        // you can replace
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/water_level.jpg',
                                          fit: BoxFit.cover,
                                          height: 20,
                                          width: 17,
                                        ),
                                        // you can replace
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/moisture.png',
                                          fit: BoxFit.cover,
                                          height: 20,
                                          width: 15,
                                        ),
                                        // you can replace
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          // you can replace this with Image.asset
                                          'assets/icons/soil_moisture.png',
                                          fit: BoxFit.cover,
                                          height: 20,
                                          width: 15,
                                        ),
                                        // you can replace
                                        CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.sensorIconColor),
                                          value: 30,
                                          strokeWidth: 3,
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 125,
                              child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  // Chart title
                                  title: ChartTitle(
                                      text: 'Weekly light chart',
                                      textStyle: GoogleFonts.openSans(),
                                      backgroundColor:
                                          AppColors.detailsIconColor),
                                  // Enable legend
                                  legend: Legend(isVisible: false),
                                  // Enable tooltip
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <ChartSeries<ChartData, String>>[
                                    AreaSeries<ChartData, String>(
                                        dataSource: lightChartData,
                                        color: AppColors.lightSensorBarColor,
                                        borderColor:
                                            AppColors.lightSensorBarColor,
                                        borderWidth: 2,
                                        borderGradient: lightGradientColors,
                                        pointColorMapper: (ChartData data, _) =>
                                            data.color,
                                        xValueMapper: (ChartData sales, _) =>
                                            sales.x,
                                        yValueMapper: (ChartData sales, _) =>
                                            sales.y,
                                        name: 'Light',
                                        gradient: lightGradientColors,
                                        dataLabelSettings:
                                            DataLabelSettings(isVisible: false))
                                  ]),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 125,
                              child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(),
                                  // Chart title
                                  title: ChartTitle(
                                      text: 'Weekly water level chart',
                                      textStyle: GoogleFonts.openSans(),
                                      backgroundColor:
                                          AppColors.detailsIconColor),
                                  // Enable legend
                                  legend: Legend(isVisible: false),
                                  // Enable tooltip
                                  tooltipBehavior:
                                      TooltipBehavior(enable: true),
                                  series: <ChartSeries<ChartData, String>>[
                                    AreaSeries<ChartData, String>(
                                        dataSource: waterChartData,
                                        color: AppColors
                                            .waterMoistureSensorBarColor,
                                        borderColor: AppColors
                                            .waterMoistureSensorBarColor,
                                        borderGradient: waterGradientColors,
                                        pointColorMapper: (ChartData data, _) =>
                                            data.color,
                                        xValueMapper: (ChartData sales, _) =>
                                            sales.x,
                                        yValueMapper: (ChartData sales, _) =>
                                            sales.y,
                                        name: 'Water Moisture',
                                        gradient: waterGradientColors,
                                        dataLabelSettings:
                                            DataLabelSettings(isVisible: false))
                                  ]),
                            )
                          ],
                        ))),
              ),
              Positioned(
                  top: 230,
                  left: 110,
                  child: Container(
                    width: 170.0,
                    height: 170.0,
                    decoration: BoxDecoration(
                      color: AppColors.detailsIconColor,
                      shape: BoxShape.circle,
                    ),
                  )),
              Positioned(
                top: 240,
                left: 125,
                child: SizedBox(
                  height: 150,
                  child: Image.network(widget.imageURL),
                ),
              ),
            ],
          )),
    );
  }
}

class PlantFeature extends StatelessWidget {
  final String plantFeature;
  final String title;
  const PlantFeature({
    Key? key,
    required this.plantFeature,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.black,
          ),
        ),
        Text(
          plantFeature,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}