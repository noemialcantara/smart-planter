import 'package:flutter/material.dart';

class ChipsList extends StatefulWidget {
  final List<String> categoryList;
  final List<String> valueList;

  ChipsList({super.key, required this.categoryList, required this.valueList});

  @override
  _ChipsListState createState() => _ChipsListState();
}

class _ChipsListState extends State<ChipsList> {
  List<String> chipList = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    widget.categoryList.forEach((element) {
      String category = element;
      if ("standard_water_profile_status" == element) {
        category = "Water Needed";
      } else if ("standard_light_intensity" == element) {
        category = "Indoor Light";
      } else if ("plant_type" == element) {
        category = "Category";
      } else if ("light_sensor" == element) {
        category = "Light Sensor";
      }

      if ("light_sensor" == element) {
        chipList
            .add(category + ": " + widget.valueList[index].split("&&&&&")[1]);
      } else {
        chipList.add(category + ": " + widget.valueList[index]);
      }

      index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
          padding: EdgeInsets.only(left: 10, right: 20),
          child: Row(
            children: chipList.map((chip) => buildChip(chip)).toList(),
          )),
    );
  }

  Widget buildChip(String chipText) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: Chip(
        backgroundColor: Color(0xffEBEDEB),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(chipText),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
