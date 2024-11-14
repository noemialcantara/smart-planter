import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:intl/intl.dart';
import 'package:hortijoy_mobile_app/models/water_reading_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesData {
  SalesData(this.date, this.data);

  final DateTime date;
  final double data;
}

class SalesDateData {
  SalesDateData(this.date, this.data);

  final DateTime date;
  final double data;
}

class WaterMonthChart extends StatelessWidget {
  final planterDetails;
  const WaterMonthChart({required this.planterDetails, super.key});

  Stream<List<WaterReadingData>> getMonthlyDataStream() async* {
    final now = DateTime.now();
    final startDate = now
        .subtract(Duration(days: 89))
        .toLocal(); // Start date for 90 days before today

    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      QuerySnapshot<Map<String, dynamic>> checkData = await FirebaseFirestore
          .instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('soil_moisture_readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: now)
          .limit(1)
          .get();

      if (checkData.docs.isNotEmpty) {
        yield* FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('soil_moisture_readings')
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

  List<WaterReadingData> parseData(
      List<QueryDocumentSnapshot> docs, DateTime startDate, DateTime endDate) {
    Map<DateTime, List<double>> dailyDataMap = {};

    // Aggregate data per day
    for (var doc in docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double waterReservoirLevel = doc['soil_moisture_level'].toDouble();

      // Normalize the timestamp to midnight
      DateTime dateOnly =
          DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (!dailyDataMap.containsKey(dateOnly)) {
        dailyDataMap[dateOnly] = [];
      }

      dailyDataMap[dateOnly]!.add(waterReservoirLevel);
    }

    List<WaterReadingData> aggregatedData = [];

    // Ensure every day in the range is included
    for (DateTime day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      DateTime normalizedDay = DateTime(day.year, day.month, day.day);

      double averagewaterReservoirLevel =
          dailyDataMap.containsKey(normalizedDay)
              ? dailyDataMap[normalizedDay]!.reduce((a, b) => a + b) /
                  dailyDataMap[normalizedDay]!.length
              : 0.0;

      aggregatedData
          .add(WaterReadingData(normalizedDay, averagewaterReservoirLevel));
    }

    // Sort by date
    aggregatedData.sort((a, b) => a.date.compareTo(b.date));

    return aggregatedData;
  }

  List<WaterReadingData> getRandomMonthlyData(DateTime endDate) {
    List<WaterReadingData> salesData = [];

    // Define the start of the period for random data, which is 7 days before the end date
    DateTime startRandomDataDate = endDate.subtract(Duration(days: 10));

    // Define the start of the overall period
    DateTime startDate = endDate
        .subtract(Duration(days: 90)); // Assuming a 90-day range for example

    // Add data for the period before the random data period with zero values
    for (DateTime day = startDate;
        day.isBefore(startRandomDataDate);
        day = day.add(Duration(days: 1))) {
      salesData.add(WaterReadingData(day, 0.0));
    }

    // Add random data for the last 7 days
    for (DateTime day = startRandomDataDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      Random random = Random();
      double randomValue = random.nextDouble() * 100;
      salesData.add(WaterReadingData(day, 0));
    }

    return salesData;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime ninetyDaysAgo = today.subtract(Duration(days: 89));
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: StreamBuilder<List<WaterReadingData>>(
            stream: getMonthlyDataStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final data = snapshot.data ?? [];

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
                  maximum: 100,
                  labelFormat: '{value}%',
                  numberFormat: NumberFormat('##0'),
                ),
                primaryXAxis: DateTimeAxis(
                  minimum: ninetyDaysAgo,
                  maximum: today,
                  intervalType: DateTimeIntervalType.days,
                  dateFormat: DateFormat.MMMd(),
                  interval: 10,
                ),
                series: <ChartSeries>[
                  SplineSeries<WaterReadingData, DateTime>(
                    animationDelay: 2.0,
                    color: AppColors.waterMoistureSensorBarColor,
                    splineType: SplineType.cardinal,
                    dataSource: data,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    xValueMapper: (WaterReadingData sales, _) => sales.date,
                    yValueMapper: (WaterReadingData sales, _) => sales.data,
                    enableTooltip: true,
                  ),
                ],
              );
            }));
  }
}

class WaterDailyChart extends StatelessWidget {
  final planterDetails;
  WaterDailyChart({required this.planterDetails, super.key});

  Stream<List<WaterReadingData>> getDailyDataStream() async* {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      QuerySnapshot<Map<String, dynamic>> checkData = await FirebaseFirestore
          .instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('soil_moisture_readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .limit(1)
          .get();

      if (checkData.docs.length > 0) {
        yield* FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('soil_moisture_readings')
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

  List<WaterReadingData> parseData(List<QueryDocumentSnapshot> docs) {
    List<WaterReadingData> completeData = [];

    // Initialize the data for each hour between 7 AM and 7 PM
    for (int hour = 7; hour <= 19; hour++) {
      DateTime timestamp = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        0,
      );
      completeData.add(WaterReadingData(timestamp, 0.0));
    }

    for (var doc in docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double waterReservoirLevel = doc['soil_moisture_level'].toDouble();
      int hour = timestamp.hour;

      // Only process the document if the hour is within the 7 AM to 7 PM range
      if (hour >= 7 && hour <= 19) {
        // Find the index of the data to replace
        WaterReadingData existingData = completeData.firstWhere(
          (data) => data.date.hour == hour,
          orElse: () => WaterReadingData(timestamp, 0.0),
        );

        int index = completeData.indexOf(existingData);
        completeData[index] = WaterReadingData(timestamp, waterReservoirLevel);
      }
    }

    return completeData;
  }

  List<WaterReadingData> getRandomDailyData() {
    List<WaterReadingData> randomData = [];
    DateTime now = DateTime.now();

    // Generate random data between 7 AM and 7 PM
    for (int hour = 7; hour <= 19; hour++) {
      DateTime timestamp = DateTime(now.year, now.month, now.day, hour, 0);
      Random random = Random();
      double randomWaterData = random.nextInt(100).toDouble();

      randomData.add(WaterReadingData(timestamp, 0.00));
    }

    return randomData;
  }

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: StreamBuilder<List<WaterReadingData>>(
            stream: getDailyDataStream(), // Fetch data as a stream
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // The data is now a List<LightReadingData>
              List<WaterReadingData> waterReadings = snapshot.data ?? [];

              return SfCartesianChart(
                borderColor: Colors.black54,
                margin: EdgeInsets.only(top: 40.0),
                legend: Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true, header: ""),
                primaryYAxis: NumericAxis(
                  maximum: 100,
                  labelFormat: '{value}%',
                ),
                zoomPanBehavior: ZoomPanBehavior(
                    enablePinching: true,
                    enablePanning: true,
                    enableSelectionZooming: true,
                    enableDoubleTapZooming: true),
                primaryXAxis: DateTimeAxis(
                    dateFormat:
                        DateFormat('HH:mm'), // This will show hours and minutes
                    intervalType: DateTimeIntervalType
                        .minutes, // Show intervals based on minutes
                    interval:
                        60, // Adjust this to show intervals (e.g., every 60 minutes)
                    minimum: DateTime(now.year, now.month, now.day, 7, 0),
                    maximum: DateTime(now.year, now.month, now.day, 19, 0)),
                series: <ChartSeries>[
                  SplineSeries<WaterReadingData, DateTime>(
                    animationDelay: 2.0,
                    color: AppColors.waterMoistureSensorBarColor,
                    splineType: SplineType.cardinal,
                    dataSource: waterReadings,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    xValueMapper: (WaterReadingData sales, _) => sales.date,
                    yValueMapper: (WaterReadingData sales, _) => sales.data,
                    enableTooltip: true,
                  ),
                ],
              );
            }));
  }
}

class WaterWeeklyChart extends StatelessWidget {
  final planterDetails;
  WaterWeeklyChart({required this.planterDetails, super.key});

  List<WaterReadingData> getRandomWeeklyData(
      DateTime startDate, DateTime endDate) {
    List<WaterReadingData> salesData = [];

    for (DateTime day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      Random random = Random();
      double randomValue = random.nextDouble() * 100;
      salesData.add(WaterReadingData(day, 0));
    }

    return salesData;
  }

  Stream<List<WaterReadingData>> getWeeklyDataStream() async* {
    final now = DateTime.now();
    final startDate = now
        .subtract(Duration(days: 6))
        .toLocal(); // Start date for 7 days before today

    QuerySnapshot<Map<String, dynamic>> userDevices = await FirebaseFirestore
        .instance
        .collection('user_plant_devices')
        .where('planter_device_name',
            isEqualTo: planterDetails.planterDeviceName)
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
        .limit(1)
        .get();

    if (userDevices.docs.isNotEmpty) {
      var deviceId = userDevices.docs.first.id;

      QuerySnapshot<Map<String, dynamic>> checkData = await FirebaseFirestore
          .instance
          .collection('user_plant_devices')
          .doc(deviceId)
          .collection('soil_moisture_readings')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: now)
          .limit(1)
          .get();

      if (checkData.docs.isNotEmpty) {
        yield* FirebaseFirestore.instance
            .collection('user_plant_devices')
            .doc(deviceId)
            .collection('soil_moisture_readings')
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

  List<WaterReadingData> parseData(
      List<QueryDocumentSnapshot> docs, DateTime startDate, DateTime endDate) {
    Map<DateTime, List<double>> dailyDataMap = {};

    // Aggregate data per day
    for (var doc in docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      double footCandle = doc['soil_moisture_level'].toDouble();

      // Normalize the timestamp to midnight
      DateTime dateOnly =
          DateTime(timestamp.year, timestamp.month, timestamp.day);

      if (!dailyDataMap.containsKey(dateOnly)) {
        dailyDataMap[dateOnly] = [];
      }

      dailyDataMap[dateOnly]!.add(footCandle);
    }

    List<WaterReadingData> aggregatedData = [];

    // Ensure every day in the range is included
    for (DateTime day = startDate;
        day.isBefore(endDate.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      DateTime normalizedDay = DateTime(day.year, day.month, day.day);

      double averageWaterLevel = dailyDataMap.containsKey(normalizedDay)
          ? dailyDataMap[normalizedDay]!.reduce((a, b) => a + b) /
              dailyDataMap[normalizedDay]!.length
          : 0.0;

      aggregatedData.add(WaterReadingData(normalizedDay, averageWaterLevel));
    }

    // Sort by date
    aggregatedData.sort((a, b) => a.date.compareTo(b.date));

    return aggregatedData;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: StreamBuilder<List<WaterReadingData>>(
            stream: getWeeklyDataStream(),
            builder: (context, snapshot) {
              final now = DateTime.now();
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              List<WaterReadingData> waterReading = snapshot.data ?? [];

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
                  maximum: 100,
                  labelFormat: '{value}%',
                ),
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('MMM dd'),
                  intervalType: DateTimeIntervalType.days,
                  interval: 1,
                  minimum: now.subtract(Duration(days: 7)),
                  maximum: now,
                ),
                series: <ChartSeries>[
                  SplineSeries<WaterReadingData, DateTime>(
                    animationDelay: 2.0,
                    color: AppColors.waterMoistureSensorBarColor,
                    splineType: SplineType.cardinal,
                    dataSource: waterReading,
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                    xValueMapper: (WaterReadingData sales, _) => sales.date,
                    yValueMapper: (WaterReadingData sales, _) => sales.data,
                    enableTooltip: true,
                  ),
                ],
              );
            }));
  }
}
