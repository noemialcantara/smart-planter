import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:intl/intl.dart';
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
        _monthlyData = getMonthlyData();
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 1000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 1100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin ? double.parse(intensity.substring(1)) : 1100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

  List<SalesDateData> getMonthlyData() {
    final now = DateTime.now();
    // Calculate the date exactly 90 days ago
    DateTime ninetyDaysAgo = now.subtract(Duration(days: 89));

    List<SalesDateData> salesData = [];
    Random random = Random();

    for (int i = 0; i < 90; i++) {
      DateTime date = ninetyDaysAgo.add(Duration(days: i));
      double sales = (date.isAfter(now.subtract(Duration(days: 14))))
          ? random.nextInt(1100).toDouble()
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
          maximum: 1100,
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
          SplineSeries<SalesDateData, DateTime>(
            animationDelay: 2.0,
            color: AppColors.lightSensorBarColor,
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

class DailyChart extends StatefulWidget {
  final planterDetails;

  DailyChart({super.key, required this.planterDetails});
  @override
  _DailyChartState createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  List<SalesDateData> _dailyData = [];
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
        _dailyData = getDailyData();
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 1000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 1100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin ? double.parse(intensity.substring(1)) : 1100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

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
      int randomNumber = random.nextInt(1100);
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
          maximum: 1100,
          labelFormat: '{value}FC',
        ),
        zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enablePanning: true,
            enableSelectionZooming: true,
            enableDoubleTapZooming: true),
        primaryXAxis: DateTimeAxis(plotBands: <PlotBand>[
          PlotBand(
            isVisible: true,
            end: DateTime(2024, 01, 24, 7, 00).add(Duration(hours: 12)),
            start: DateTime(2024, 01, 24, 7, 00),
            associatedAxisStart: _lightIntensitySunnyMin,
            associatedAxisEnd: _lightIntensitySunnyMax,
            shouldRenderAboveSeries: false,
            color: const Color(0xfffff9da),
          ),
          PlotBand(
            isVisible: true,
            end: DateTime(2024, 01, 24, 7, 00).add(Duration(hours: 12)),
            start: DateTime(2024, 01, 24, 7, 00),
            associatedAxisStart: _lightIntensityDarkMin,
            associatedAxisEnd: _lightIntensityDarkMax,
            shouldRenderAboveSeries: false,
            color: const Color(0xffebedeb),
          )
        ]),
        series: <ChartSeries>[
          SplineSeries<SalesDateData, DateTime>(
            animationDelay: 2.0,
            color: AppColors.lightSensorBarColor,
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
        _weeklyData = getWeeklyData();
      });
    }
  }

  void _parseLightIntensity(Map<String, dynamic> data) {
    String darkIntensity = data["light_intensity_dark"];
    String sunnyIntensity = data["light_intensity_too_sunny"];

    _lightIntensityDarkMin = _parseIntensityValue(darkIntensity, isMin: true);
    _lightIntensityDarkMax = _parseIntensityValue(darkIntensity, isMin: false);
    _lightIntensitySunnyMin =
        _parseIntensityValue(sunnyIntensity, isMin: true) ?? 1000;
    _lightIntensitySunnyMax =
        _parseIntensityValue(sunnyIntensity, isMin: false) ?? 1100;
  }

  double? _parseIntensityValue(String intensity, {required bool isMin}) {
    if (intensity.startsWith('>')) {
      return isMin ? double.parse(intensity.substring(1)) : 1100;
    } else if (intensity.startsWith('<')) {
      return isMin ? 0 : double.parse(intensity.substring(1));
    } else if (intensity.contains('-')) {
      var parts = intensity.split('-');
      return isMin ? double.parse(parts[0]) : double.parse(parts[1]);
    }
    return null;
  }

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
      int randomNumber = random.nextInt(1100);
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
          maximum: 1100,
          labelFormat: '{value}FC',
        ),
        primaryXAxis: DateTimeAxis(plotBands: <PlotBand>[
          PlotBand(
            isVisible: true,
            end: DateTime.now(),
            start: DateTime.now().subtract(Duration(days: 7)),
            associatedAxisStart: _lightIntensitySunnyMin,
            associatedAxisEnd: _lightIntensitySunnyMax,
            shouldRenderAboveSeries: false,
            color: const Color(0xfffff9da),
          ),
          PlotBand(
            isVisible: true,
            end: DateTime.now(),
            start: DateTime.now().subtract(Duration(days: 7)),
            associatedAxisStart: _lightIntensityDarkMin,
            associatedAxisEnd: _lightIntensityDarkMax,
            shouldRenderAboveSeries: false,
            color: const Color(0xffebedeb),
          )
        ]),
        series: <ChartSeries>[
          SplineSeries<SalesDateData, DateTime>(
            animationDelay: 2.0,
            color: AppColors.lightSensorBarColor,
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
