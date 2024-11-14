import 'package:async_task/async_task_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hortijoy_mobile_app/resources/shared_pref_service.dart';

class FirebaseQueries {
  static Future getUserData(String email) async {
    var username = await FirebaseFirestore.instance
        .collection("user")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    return username.docs.first.get("name");
  }

  static Future<dynamic> getPlantLibrary() async {
    final CollectionReference plant_library =
        FirebaseFirestore.instance.collection("plant_library_test_first");

    return plant_library;
  }

  static Future postUserPlantDevices(
      String email, String planter_name, String location) async {
    var add_user_planter_device =
        await FirebaseFirestore.instance.collection("user_plant_devices").add({
      "email": email,
      "planter_name": planter_name,
      "description": location,
      "planter_device_name": planter_name,
      "is_already_profiled": false,
      "max_moisture_level": "",
      "max_sunlight_hour": "",
      "min_moisture_level": "",
      "min_sunlight_hour": "",
      "plant_name": "",
      "species_name": "",
      "type": "indoor",
      "uid": "",
      "water_scale_warning_level": "1",
      "image_url":
          "https://www.pulsecarshalton.co.uk/wp-content/uploads/2016/08/jk-placeholder-image.jpg",
      "watering_care_profile_information": "",
      "sunlight_care_profile_information": "",
      "is_fertilizer_turned_on": false,
      "is_light_sensor_turned_on": true,
      "is_reservoir_sensor_turned_on": false,
      "is_water_sensor_turned_on": false
    });

    return add_user_planter_device.id;
  }

  static Future updatePlantDevices(
      String uid, String wifiName, String wifiPassword) async {
    final collection =
        await FirebaseFirestore.instance.collection("user_plant_devices");

    print('-----------UID from sharedpreference----------');
    print(uid);
    print(wifiName);
    print(wifiPassword);
    final document = collection.doc(uid).update({
      "wifi_name": wifiName,
      "wifi_password": wifiPassword,
      "uid": uid,
    });

    return document;
  }

  static Future updatePlantDeviceFromPlantLibrary(
      String uidOFPlantDevice,
      String imageUrl,
      String maxMoistureLevel,
      String maxSunlightHr,
      String minMoisLvl,
      String minSunLightHr,
      String plantName,
      String speciesName,
      String type,
      String waterScaleWarningLvl) async {
    final collection =
        await FirebaseFirestore.instance.collection("user_plant_devices");

    final document = collection.doc(uidOFPlantDevice).update({
      "image_url": imageUrl,
      "max_moisture_level": maxMoistureLevel,
      "max_sunlight_hour": maxSunlightHr,
      "min_moisture_level": minMoisLvl,
      "min_sunlight_hour": minSunLightHr,
      "plant_name": plantName,
      "species_name": speciesName,
      "type": type,
      "water_scale_warning_level": waterScaleWarningLvl,
      "is_already_profiled": true
    });

    return document;
  }
}
