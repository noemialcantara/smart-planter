import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:intl/intl.dart';
import 'package:hortijoy_mobile_app/models/light_reading_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesDateData {
  SalesDateData(this.date, this.data);

  final DateTime date;
  final double data;
}

class MonthChart extends StatefulWidget {
  final planterDetails;
  const MonthChart({super.key, required this.planterDetails});

  @override
  _MonthChartState createState() => _MonthChartState();
}

class _MonthChartState extends State<MonthChart> {
  List<SalesDateData> _monthlyData = [];
  double? _lightIntensityDarkMin;
  double? _lightIntensityDarkMax;
  double? _lightIntensitySunnyMin;
  double? _lightIntensitySunnyMax;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var fileDocument = await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names", isEqualTo: widget.planterDetails.plantName)
        .limit(1)
        .get();

    if (fileDocument.docs.isNotEmpty) {
      setState(() {
        _parseLightIntensity(fileDocument.docs.first.data());
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 2000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 2100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin
          ? double.parse(intensity.substring(1))
          : double.parse(intensity.substring(1)) + 100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

  List<LightReadingData> getRandomMonthlyData(DateTime endDate) {
    List<LightReadingData> salesData = [];

    // Define the start of the period for random data, which is 7 days before the end date
    DateTime startRandomDataDate = endDate.subtract(Duration(days: 10));

    // Define the start of the overall period
    DateTime startDate = endDate
        .subtract(Duration(days: 90)); // Assuming a 90-day range for example

    // Add data for the period before the random data period with zero values
    for (DateTime day = startDate;
        day.isBefore(startRandomDataDate);
        day = day.add(Duration(days: 1))) {
      salesData.add(LightReadingData(day, 0.0));
    }

    // Add random data for the last 7 days
    for (DateTime day = startRandomDataDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      Random random = Random();
      double randomValue =
          random.nextDouble() * 1100; // Random value between 0 and 1100
      salesData.add(LightReadingData(day, 0));
    }

    return salesData;
  }

  Stream<List<LightReadingData>> getMonthlyDataStream() async* {
    final now = DateTime.now();
    final startDate = now
        .subtract(Duration(days: 89))
        .toLocal(); // Start date for 90 days before today

    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      QuerySnapshot<Map<String, dynamic>> checkData = await FirebaseFirestore
          .instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('light_readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: now)
          .limit(1)
          .get();

      if (checkData.docs.isNotEmpty) {
        yield* FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('light_readings')
            .where('timestamp', isGreaterThanOrEqualTo: startDate)
            .where('timestamp', isLessThanOrEqualTo: now)
            .snapshots()
            .map((snapshot) {
          return parseData(snapshot.docs, startDate, now);
        });
      } else {
        yield getRandomMonthlyData(now);
      }
    } else {
      yield getRandomMonthlyData(now);
    }
  }

  List<LightReadingData> parseData(
      List<QueryDocumentSnapshot> docs, DateTime startDate, DateTime endDate) {
    Map<DateTime, List<double>> dailyDataMap = {};

    // Aggregate data per day
    for (var doc in docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double footCandle = doc['foot_candle'].toDouble();

      // Normalize the timestamp to midnight
      DateTime dateOnly =
          DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (!dailyDataMap.containsKey(dateOnly)) {
        dailyDataMap[dateOnly] = [];
      }

      dailyDataMap[dateOnly]!.add(footCandle);
    }

    List<LightReadingData> aggregatedData = [];

    // Ensure every day in the range is included
    for (DateTime day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      DateTime normalizedDay = DateTime(day.year, day.month, day.day);

      double averageFootCandle = dailyDataMap.containsKey(normalizedDay)
          ? dailyDataMap[normalizedDay]!.reduce((a, b) => a + b) /
              dailyDataMap[normalizedDay]!.length
          : 0.0;

      aggregatedData.add(LightReadingData(normalizedDay, averageFootCandle));
    }

    // Sort by date
    aggregatedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return aggregatedData;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime ninetyDaysAgo = today.subtract(Duration(days: 89));

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: StreamBuilder<List<LightReadingData>>(
          stream: getMonthlyDataStream(),
          builder: (context, snapshot) {
            final now = DateTime.now();
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            List<LightReadingData> lightReadings = snapshot.data ?? [];

            return SfCartesianChart(
              borderColor: Colors.black54,
              margin: EdgeInsets.only(top: 40.0),
              legend: Legend(isVisible: false),
              tooltipBehavior: TooltipBehavior(enable: true, header: ""),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableSelectionZooming: true,
                  enableDoubleTapZooming: true),
              primaryYAxis: NumericAxis(
                maximum: _lightIntensitySunnyMax,
                labelFormat: '{value}FC',
              ),
              primaryXAxis: DateTimeAxis(
                minimum: ninetyDaysAgo,
                maximum: today,
                intervalType: DateTimeIntervalType.days,
                dateFormat: DateFormat.MMMd(),
                interval: 10,
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: ninetyDaysAgo,
                    end: today,
                    associatedAxisStart: _lightIntensitySunnyMin,
                    associatedAxisEnd: _lightIntensitySunnyMax,
                    shouldRenderAboveSeries: false,
                    color: const Color(0xfffff9da),
                  ),
                  PlotBand(
                    isVisible: true,
                    start: ninetyDaysAgo,
                    end: today,
                    associatedAxisStart: _lightIntensityDarkMin,
                    associatedAxisEnd: _lightIntensityDarkMax,
                    shouldRenderAboveSeries: false,
                    color: const Color(0xffebedeb),
                  ),
                ],
              ),
              series: <ChartSeries>[
                SplineSeries<LightReadingData, DateTime>(
                  animationDelay: 2.0,
                  color: AppColors.lightSensorBarColor,
                  splineType: SplineType.cardinal,
                  dataSource: lightReadings,
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  xValueMapper: (LightReadingData sales, _) => sales.timestamp,
                  yValueMapper: (LightReadingData sales, _) => sales.footCandle,
                  enableTooltip: true,
                ),
              ],
            );
          }),
    );
  }
}

class DailyChart extends StatefulWidget {
  final planterDetails;

  DailyChart({super.key, required this.planterDetails});
  @override
  _DailyChartState createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  List<LightReadingData> _dailyData = [];
  double? _lightIntensityDarkMin;
  double? _lightIntensityDarkMax;
  double? _lightIntensitySunnyMin;
  double? _lightIntensitySunnyMax;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // _insertSampleDailyData();
    _fetchData();
  }

  _insertSampleDailyData() {
    const deviceId = 'yKofIPYYBaiiEUOPalsl';

    final List<Map<String, dynamic>> waterReadings = [
      {
        'timestamp': DateTime.utc(2024, 8, 15, 12, 0),
        'water_reservoir_level': 150.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 12, 30),
        'water_reservoir_level': 180.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 13, 0),
        'water_reservoir_level': 200.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 13, 30),
        'water_reservoir_level': 220.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 14, 0),
        'water_reservoir_level': 210.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 14, 30),
        'water_reservoir_level': 190.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 15, 0),
        'water_reservoir_level': 170.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 15, 30),
        'water_reservoir_level': 160.0
      },
      {
        'timestamp': DateTime.utc(2024, 8, 15, 16, 0),
        'water_reservoir_level': 155.0
      },
    ];

    waterReadings.forEach((element) {
      FirebaseFirestore.instance
          .collection("user_plant_devices")
          .doc(deviceId)
          .collection('water_readings')
          .add(element);
    });
  }

  Stream<List<LightReadingData>> getDailyDataStream() async* {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      QuerySnapshot<Map<String, dynamic>> checkData = await FirebaseFirestore
          .instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('light_readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .limit(1)
          .get();

      if (checkData.docs.isNotEmpty) {
        yield* FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('light_readings')
            .where('timestamp', isGreaterThanOrEqualTo: startDate)
            .where('timestamp', isLessThanOrEqualTo: endDate)
            .snapshots()
            .map((snapshot) {
          return parseData(snapshot.docs);
        });
      } else {
        yield getRandomDailyData();
      }
    } else {
      yield getRandomDailyData();
    }
  }

  List<LightReadingData> parseData(List<QueryDocumentSnapshot> docs) {
    List<LightReadingData> completeData = [];

    // Initialize the data for each hour between 7 AM and 7 PM
    // for (int hour = 7; hour <= 19; hour++) {
    //   completeData.add(LightReadingData(
    //     DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
    //         hour, 0),
    //     0.0, // Default foot candle value
    //   ));
    // }

    completeData.add(LightReadingData(
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 0),
      0.0, // Default foot candle value
    ));

    // Process the fetched documents
    for (var doc in docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double footCandle = doc['foot_candle'].toDouble();
      int hour = timestamp.hour;

      // Only process the document if the hour is within the 7 AM to 7 PM range
      if (hour >= 7 && hour <= 19) {
        // Find the index of the hour in completeData
        int index = hour - 7; // Since completeData starts from 7 AM

        // Create a new LightReadingData with the timestamp and foot candle
        completeData.add(LightReadingData(timestamp, footCandle));
      }
    }

    // If you want to keep the existing hourly data, you may want to remove duplicates or handle merging
    // Optionally, sort the completeData based on the timestamp
    completeData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return completeData;
  }

  Future<void> _fetchData() async {
    var fileDocument = await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names", isEqualTo: widget.planterDetails.plantName)
        .limit(1)
        .get();

    if (fileDocument.docs.isNotEmpty) {
      setState(() {
        _parseLightIntensity(fileDocument.docs.first.data());
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 2000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 2100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin
          ? double.parse(intensity.substring(1))
          : double.parse(intensity.substring(1)) + 100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

  List<LightReadingData> getRandomDailyData() {
    List<LightReadingData> randomData = [];
    DateTime now = DateTime.now();

    // Generate random data between 7 AM and 7 PM
    for (int hour = 7; hour <= 19; hour++) {
      DateTime timestamp = DateTime(now.year, now.month, now.day, hour, 0);
      Random random = Random();
      double randomFootCandle = random.nextInt(1100).toDouble();

      randomData.add(LightReadingData(timestamp, 0.00));
    }

    return randomData;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: StreamBuilder<List<LightReadingData>>(
            stream: getDailyDataStream(), // Fetch data as a stream
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // The data is now a List<LightReadingData>
              List<LightReadingData> lightReadings = snapshot.data ?? [];

              return SfCartesianChart(
                borderColor: Colors.black54,
                margin: EdgeInsets.only(top: 40.0),
                legend: Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true, header: ""),
                primaryYAxis: NumericAxis(
                  maximum: _lightIntensitySunnyMax,
                  labelFormat: '{value}FC',
                ),
                zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true,
                    enablePanning: true,
                    enableSelectionZooming: true,
                    enableDoubleTapZooming: true),
                primaryXAxis: DateTimeAxis(
                    minimum: DateTime(now.year, now.month, now.day, 7, 0),
                    maximum: DateTime(now.year, now.month, now.day, 19, 0),
                    dateFormat:
                        DateFormat('HH:mm'), // This will show hours and minutes
                    intervalType: DateTimeIntervalType
                        .minutes, // Show intervals based on minutes
                    interval:
                        60, // Adjust this to show intervals (e.g., every 60 minutes)
                    plotBands: <PlotBand>[
                      PlotBand(
                        isVisible: true,
                        end: DateTime(now.year, now.month, now.day, 7, 00)
                            .add(Duration(hours: 13)),
                        start: DateTime(now.year, now.month, now.day, 7, 00),
                        associatedAxisStart: _lightIntensitySunnyMin,
                        associatedAxisEnd: _lightIntensitySunnyMax,
                        shouldRenderAboveSeries: false,
                        color: const Color(0xfffff9da),
                      ),
                      PlotBand(
                        isVisible: true,
                        end: DateTime(now.year, now.month, now.day, 7, 00)
                            .add(Duration(hours: 13)),
                        start: DateTime(now.year, now.month, now.day, 7, 00),
                        associatedAxisStart: _lightIntensityDarkMin,
                        associatedAxisEnd: _lightIntensityDarkMax,
                        shouldRenderAboveSeries: false,
                        color: const Color(0xffebedeb),
                      )
                    ]),
                series: <ChartSeries>[
                  SplineSeries<LightReadingData, DateTime>(
                    animationDelay: 2.0,
                    color: AppColors.lightSensorBarColor,
                    splineType: SplineType.cardinal,
                    dataSource: lightReadings,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    xValueMapper: (LightReadingData sales, _) =>
                        sales.timestamp,
                    yValueMapper: (LightReadingData sales, _) =>
                        sales.footCandle,
                    enableTooltip: true,
                  ),
                ],
              );
            }));
  }
}

class WeeklyChart extends StatefulWidget {
  final planterDetails;
  const WeeklyChart({super.key, required this.planterDetails});

  @override
  _WeeklyChartState createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  List<SalesDateData> _weeklyData = [];
  double? _lightIntensityDarkMin;
  double? _lightIntensityDarkMax;
  double? _lightIntensitySunnyMin;
  double? _lightIntensitySunnyMax;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var fileDocument = await FirebaseFirestore.instance
        .collection("plant_library_test_first")
        .where("common_names", isEqualTo: widget.planterDetails.plantName)
        .limit(1)
        .get();

    if (fileDocument.docs.isNotEmpty) {
      setState(() {
        _parseLightIntensity(fileDocument.docs.first.data());
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 2000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 2100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin
          ? double.parse(intensity.substring(1))
          : double.parse(intensity.substring(1)) + 100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

  List<LightReadingData> getRandomWeeklyData(
      DateTime startDate, DateTime endDate) {
    List<LightReadingData> salesData = [];

    for (DateTime day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      Random random = Random();
      double randomValue =
          random.nextDouble() * 1100; // Random value between 0 and 1100
      salesData.add(LightReadingData(day, 0));
    }

    return salesData;
  }

  Stream<List<LightReadingData>> getWeeklyDataStream() async* {
    final now = DateTime.now();
    final startDate = now
        .subtract(Duration(days: 6))
        .toLocal(); // Start date for 7 days before today

    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: widget.planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      QuerySnapshot<Map<String, dynamic>> checkData = await FirebaseFirestore
          .instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('light_readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: now)
          .limit(1)
          .get();

      if (checkData.docs.isNotEmpty) {
        yield* FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('light_readings')
            .where('timestamp', isGreaterThanOrEqualTo: startDate)
            .where('timestamp', isLessThanOrEqualTo: now)
            .snapshots()
            .map((snapshot) {
          return parseData(snapshot.docs, startDate, now);
        });
      } else {
        yield getRandomWeeklyData(startDate, now);
      }
    } else {
      yield getRandomWeeklyData(startDate, now);
    }
  }

  List<LightReadingData> parseData(
      List<QueryDocumentSnapshot> docs, DateTime startDate, DateTime endDate) {
    Map<DateTime, List<double>> dailyDataMap = {};

    // Aggregate data per day
    for (var doc in docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double footCandle = doc['foot_candle'].toDouble();

      // Normalize the timestamp to midnight
      DateTime dateOnly =
          DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (!dailyDataMap.containsKey(dateOnly)) {
        dailyDataMap[dateOnly] = [];
      }

      dailyDataMap[dateOnly]!.add(footCandle);
    }

    List<LightReadingData> aggregatedData = [];

    // Ensure every day in the range is included
    for (DateTime day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      DateTime normalizedDay = DateTime(day.year, day.month, day.day);

      double averageFootCandle = dailyDataMap.containsKey(normalizedDay)
          ? dailyDataMap[normalizedDay]!.reduce((a, b) => a + b) /
              dailyDataMap[normalizedDay]!.length
          : 0.0;

      aggregatedData.add(LightReadingData(normalizedDay, averageFootCandle));
    }

    // Sort by date
    aggregatedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return aggregatedData;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: StreamBuilder<List<LightReadingData>>(
        stream: getWeeklyDataStream(),
        builder: (context, snapshot) {
          final now = DateTime.now();
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<LightReadingData> lightReadings = snapshot.data ?? [];

          return SfCartesianChart(
            borderColor: Colors.black54,
            margin: EdgeInsets.only(top: 40.0),
            legend: Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(enable: true, header: ""),
            primaryYAxis: NumericAxis(
              maximum: _lightIntensitySunnyMax,
              labelFormat: '{value}FC',
            ),
            zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true,
                enablePanning: true,
                enableSelectionZooming: true,
                enableDoubleTapZooming: true),
            primaryXAxis: DateTimeAxis(
                intervalType: DateTimeIntervalType.days,
                dateFormat: DateFormat('MMM dd'),
                interval: 1,
                minimum: now.subtract(Duration(days: 7)),
                maximum: now,
                plotBands: <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    end: now,
                    start: now.subtract(Duration(days: 7)),
                    associatedAxisStart: _lightIntensitySunnyMin,
                    associatedAxisEnd: _lightIntensitySunnyMax,
                    shouldRenderAboveSeries: false,
                    color: const Color(0xfffff9da),
                  ),
                  PlotBand(
                    isVisible: true,
                    end: now,
                    start: now.subtract(Duration(days: 7)),
                    associatedAxisStart: _lightIntensityDarkMin,
                    associatedAxisEnd: _lightIntensityDarkMax,
                    shouldRenderAboveSeries: false,
                    color: const Color(0xffebedeb),
                  )
                ]),
            series: <ChartSeries>[
              SplineSeries<LightReadingData, DateTime>(
                animationDelay: 2.0,
                color: AppColors.lightSensorBarColor,
                splineType: SplineType.cardinal,
                dataSource: lightReadings,
                dataLabelSettings: DataLabelSettings(isVisible: false),
                xValueMapper: (LightReadingData sales, _) => sales.timestamp,
                yValueMapper: (LightReadingData sales, _) => sales.footCandle,
                enableTooltip: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

var data = [20.0, 30.0, 20.0, 10.0, 40.0, 75.0, 53.0, 7.0, 80.0];

class DayLightChartSpark extends StatelessWidget {
  const DayLightChartSpark({super.key});

  @override
  Widget build(BuildContext context) {
    return Sparkline(
      min: 0,
      max: 100,
      data: data,
      useCubicSmoothing: true,
      cubicSmoothingFactor: 0.2,
    );
  }
}
