class PlantDevices {
  String description;
  String maxMoistureLevel;
  String maxSunlightHour;
  String minMoistureLevel;
  String minSunlightHour;
  String plantName;
  String speciesName;
  String type;
  String waterScaleWarningLevel;
  String imageURL;
  String isAlreadyProfiled;
  String planterDeviceURL;
  String planterDeviceName;
  String uid;
  String wateringCareProfileInformation;
  String sunlightCareProfileInformation;
  bool isLightSensorTurnedOn;
  bool isWaterSensorTurnedOn;
  bool isReservoirSensorTurnedOn;
  bool isFertilizerTurnedOn;

  PlantDevices(
      {required this.description,
      required this.uid,
      required this.maxMoistureLevel,
      required this.maxSunlightHour,
      required this.minMoistureLevel,
      required this.minSunlightHour,
      required this.plantName,
      required this.speciesName,
      required this.type,
      required this.waterScaleWarningLevel,
      required this.imageURL,
      required this.isAlreadyProfiled,
      required this.planterDeviceName,
      required this.planterDeviceURL,
      required this.wateringCareProfileInformation,
      required this.sunlightCareProfileInformation,
      required this.isLightSensorTurnedOn,
      required this.isWaterSensorTurnedOn,
      required this.isFertilizerTurnedOn,
      required this.isReservoirSensorTurnedOn});
}
