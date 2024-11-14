class Plant {
  final String botanicalName;
  final String commonNames;
  final String fertilizerFrequency;
  final String fertilizerSeason;
  final String fertilizerStrength;
  final String hasAirCleaner;
  final String lightIntensityDark;
  final String lightIntensityIdeal;
  final String lightIntensitySufficient;
  final String lightIntensityTooSunny;
  final String plantImageUrl;
  final String plantType;
  final String standardLightIntensity;
  final String standardWaterProfileStatus;
  final String waterStatus;
  final String waterStatusPercentage;
  final String plantDescription;
  final String wateringCareProfileInformation;
  final String sunlightCareProfileInformation;

  Plant(
      {required this.botanicalName,
      required this.commonNames,
      required this.fertilizerFrequency,
      required this.fertilizerSeason,
      required this.fertilizerStrength,
      required this.hasAirCleaner,
      required this.lightIntensityDark,
      required this.lightIntensityIdeal,
      required this.lightIntensitySufficient,
      required this.lightIntensityTooSunny,
      required this.plantImageUrl,
      required this.plantType,
      required this.standardLightIntensity,
      required this.standardWaterProfileStatus,
      required this.waterStatus,
      required this.waterStatusPercentage,
      this.plantDescription = "",
      required this.wateringCareProfileInformation,
      required this.sunlightCareProfileInformation});
}
