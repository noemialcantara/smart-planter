import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:intl/intl.dart';
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
  const WaterMonthChart({super.key});

  List<SalesDateData> getMonthlyData() {
    final now = DateTime.now();
    // Calculate the date exactly 90 days ago
    DateTime ninetyDaysAgo = now.subtract(Duration(days: 89));

    List<SalesDateData> salesData = [];
    Random random = Random();

    for (int i = 0; i < 90; i++) {
      DateTime date = ninetyDaysAgo.add(Duration(days: i));
      double sales = (date.isAfter(now.subtract(Duration(days: 14))))
          ? random.nextInt(100).toDouble()
          : 0.0;
      SalesDateData data = SalesDateData(date, sales);
      salesData.add(data);
    }

    return salesData;
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    DateTime ninetyDaysAgo = today.subtract(Duration(days: 89));
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SfCartesianChart(
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
          minimum: ninetyDaysAgo,
          maximum: today,
          intervalType: DateTimeIntervalType.days,
          dateFormat: DateFormat.MMMd(),
          interval: 10,
        ),
        series: <ChartSeries>[
          SplineSeries<SalesDateData, DateTime>(
            animationDelay: 2.0,
            color: AppColors.waterMoistureSensorBarColor,
            splineType: SplineType.cardinal,
            dataSource: getMonthlyData(),
            dataLabelSettings: DataLabelSettings(isVisible: false),
            xValueMapper: (SalesDateData sales, _) => sales.date,
            yValueMapper: (SalesDateData sales, _) => sales.data,
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}

class WaterDailyChart extends StatelessWidget {
  WaterDailyChart({super.key});

  List<SalesDateData> getDailyData() {
    final now = DateTime(2024, 01, 24, 19, 00);
    List<SalesDateData> salesData = [];

    DateTime daily = DateTime(2024, 01, 24, 7, 00);

    for (int i = 1; i <= 12; i++) {
      if (i == 1) {
        daily = now;
      } else {
        daily = now.subtract(Duration(hours: i));
      }

      Random random = new Random();
      int randomNumber = random.nextInt(100);
      double sales = randomNumber.toDouble();

      SalesDateData data = SalesDateData(daily, sales);
      salesData.add(data);
    }
    return salesData.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SfCartesianChart(
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
        primaryXAxis: DateTimeAxis(),
        series: <ChartSeries>[
          SplineSeries<SalesDateData, DateTime>(
            animationDelay: 2.0,
            color: AppColors.waterMoistureSensorBarColor,
            splineType: SplineType.cardinal,
            dataSource: getDailyData(),
            dataLabelSettings: DataLabelSettings(isVisible: false),
            xValueMapper: (SalesDateData sales, _) => sales.date,
            yValueMapper: (SalesDateData sales, _) => sales.data,
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}

class WaterWeeklyChart extends StatelessWidget {
  WaterWeeklyChart({super.key});

  List<SalesDateData> getWeeklyData() {
    final now = DateTime.now();
    List<SalesDateData> salesData = [];
    DateTime weekly = now;

    for (int i = 1; i <= 7; i++) {
      if (i == 1) {
        weekly = now;
      } else {
        weekly = now.subtract(Duration(days: i));
      }

      Random random = new Random();
      int randomNumber = random.nextInt(100);
      double sales = randomNumber.toDouble();

      SalesDateData data = SalesDateData(weekly, sales);
      salesData.add(data);
    }
    return salesData.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SfCartesianChart(
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
        primaryXAxis: DateTimeAxis(),
        series: <ChartSeries>[
          SplineSeries<SalesDateData, DateTime>(
            animationDelay: 2.0,
            color: AppColors.waterMoistureSensorBarColor,
            splineType: SplineType.cardinal,
            dataSource: getWeeklyData(),
            dataLabelSettings: DataLabelSettings(isVisible: false),
            xValueMapper: (SalesDateData sales, _) => sales.date,
            yValueMapper: (SalesDateData sales, _) => sales.data,
            enableTooltip: true,
          ),
        ],
      ),
    );
  }
}
