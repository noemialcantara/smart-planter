import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/models/chart_data.dart';
import 'package:hortijoy_mobile_app/models/plants.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DetailPage extends StatefulWidget {
  final String plantId;
  final String plantName;
  final String imageURL;
  const DetailPage(
      {Key? key,
      required this.plantId,
      required this.plantName,
      required this.imageURL})
      : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
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
        body: Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.white,
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: AppColors.primaryColor)),
              //  title: Text(widget.plantName,
              // style: GoogleFonts.openSans(
              //               color: AppColors.primaryColor,
              //               fontWeight: FontWeight.bold,
              //               fontSize: 17.0,
              //             ),),

              expandedHeight: 200,
              pinned: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: Text(
                  widget.plantName,
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 37.0,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    topLeft: Radius.circular(50),
                  ),
                ),
                child: CircleAvatar(
                    backgroundColor: AppColors.detailsIconColor,
                    radius: 75,
                    child: Image.network(widget.imageURL)),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(
              padding: const EdgeInsets.only(top: 15, left: 30, right: 30),
              height: size.height * .14,
              width: size.width,
              decoration: const BoxDecoration(
                color: AppColors.white,
                // borderRadius: BorderRadius.only(
                //   topRight: Radius.circular(50),
                //   topLeft: Radius.circular(50),
                // ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Focus",
                        style: GoogleFonts.openSans(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600),
                      )),
                  const SizedBox(
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
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.sensorIconColor),
                                value: 30,
                                strokeWidth: 3,
                              ),
                            ],
                          )),
                    ],
                  ),
                ],
              ),
            )),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                height: 115,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(
                        text: 'Weekly light chart',
                        textStyle: GoogleFonts.openSans(),
                        backgroundColor: AppColors.detailsIconColor),
                    // Enable legend
                    legend: Legend(isVisible: false),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<ChartData, String>>[
                      AreaSeries<ChartData, String>(
                          dataSource: lightChartData,
                          color: AppColors.lightSensorBarColor,
                          borderColor: AppColors.lightSensorBarColor,
                          borderWidth: 2,
                          borderGradient: lightGradientColors,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          name: 'Light',
                          gradient: lightGradientColors,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false))
                    ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                height: 115,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(
                        text: 'Weekly water level chart',
                        textStyle: GoogleFonts.openSans(),
                        backgroundColor: AppColors.detailsIconColor),
                    // Enable legend
                    legend: Legend(isVisible: false),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<ChartData, String>>[
                      AreaSeries<ChartData, String>(
                          dataSource: waterChartData,
                          color: AppColors.waterMoistureSensorBarColor,
                          borderColor: AppColors.waterMoistureSensorBarColor,
                          borderGradient: waterGradientColors,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          name: 'Water Moisture',
                          gradient: waterGradientColors,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false))
                    ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                height: 115,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(
                        text: 'Weekly light chart',
                        textStyle: GoogleFonts.openSans(),
                        backgroundColor: AppColors.detailsIconColor),
                    // Enable legend
                    legend: Legend(isVisible: false),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<ChartData, String>>[
                      AreaSeries<ChartData, String>(
                          dataSource: lightChartData,
                          color: AppColors.lightSensorBarColor,
                          borderColor: AppColors.lightSensorBarColor,
                          borderWidth: 2,
                          borderGradient: lightGradientColors,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          name: 'Light',
                          gradient: lightGradientColors,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false))
                    ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                height: 115,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(
                        text: 'Weekly water level chart',
                        textStyle: GoogleFonts.openSans(),
                        backgroundColor: AppColors.detailsIconColor),
                    // Enable legend
                    legend: Legend(isVisible: false),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<ChartData, String>>[
                      AreaSeries<ChartData, String>(
                          dataSource: waterChartData,
                          color: AppColors.waterMoistureSensorBarColor,
                          borderColor: AppColors.waterMoistureSensorBarColor,
                          borderGradient: waterGradientColors,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          name: 'Water Moisture',
                          gradient: waterGradientColors,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false))
                    ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                height: 115,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(
                        text: 'Weekly light chart',
                        textStyle: GoogleFonts.openSans(),
                        backgroundColor: AppColors.detailsIconColor),
                    // Enable legend
                    legend: Legend(isVisible: false),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<ChartData, String>>[
                      AreaSeries<ChartData, String>(
                          dataSource: lightChartData,
                          color: AppColors.lightSensorBarColor,
                          borderColor: AppColors.lightSensorBarColor,
                          borderWidth: 2,
                          borderGradient: lightGradientColors,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          name: 'Light',
                          gradient: lightGradientColors,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false))
                    ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(left: 30, right: 30),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                ),
                height: 115,
                child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    // Chart title
                    title: ChartTitle(
                        text: 'Weekly water level chart',
                        textStyle: GoogleFonts.openSans(),
                        backgroundColor: AppColors.detailsIconColor),
                    // Enable legend
                    legend: Legend(isVisible: false),
                    // Enable tooltip
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<ChartData, String>>[
                      AreaSeries<ChartData, String>(
                          dataSource: waterChartData,
                          color: AppColors.waterMoistureSensorBarColor,
                          borderColor: AppColors.waterMoistureSensorBarColor,
                          borderGradient: waterGradientColors,
                          pointColorMapper: (ChartData data, _) => data.color,
                          xValueMapper: (ChartData sales, _) => sales.x,
                          yValueMapper: (ChartData sales, _) => sales.y,
                          name: 'Water Moisture',
                          gradient: waterGradientColors,
                          dataLabelSettings:
                              DataLabelSettings(isVisible: false))
                    ]),
              ),
            ),
          ],
        ),
        //_image()
      ],
    ));
  }

  Widget _image() {
    final double defaultMargin = 250;
    final double defaultStart = 230;
    final double defaultEnd = defaultStart / 2;

    double top = defaultMargin;

    double scale = 1.0;

    return Positioned(
      top: 220,
      right: 130,
      child: CircleAvatar(
          backgroundColor: AppColors.detailsIconColor,
          radius: 75,
          child: Image.network(widget.imageURL)),
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
          style: const TextStyle(
            color: AppColors.black,
          ),
        ),
        Text(
          plantFeature,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
