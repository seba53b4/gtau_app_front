List<dynamic> getFeaturesArray(Map<String, dynamic> geoJson) {
  List<dynamic> featuresArray = [];

  if (geoJson.containsKey("features") && geoJson["features"] is List) {
    for (var feature in geoJson["features"]) {
      featuresArray.add(feature);
    }
  }

  return featuresArray;
}
