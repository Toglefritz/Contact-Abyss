
/// A class representing sensor data associated with a game node.
///
/// [SensorData] includes various environmental readings and status indicators
/// that influence the player's decisions and the game's progression.
class SensorData {
  /// The current radiation level detected, represented as a string descriptor.
  ///
  /// Examples include "Low", "Moderate", "High", etc.
  final String? radiationLevel;

  /// Additional sensor readings or environmental features.
  ///
  /// This map can include various other sensor data points as needed.
  final Map<String, dynamic>? additionalData;

  /// Creates a new instance of [SensorData].
  ///
  /// - [batteryLevel]: The current battery level percentage.
  /// - [radiationLevel]: Optional radiation level descriptor.
  /// - [additionalData]: Optional map of additional sensor data.
  SensorData({
    this.radiationLevel,
    this.additionalData,
  });

  /// Creates a [SensorData] instance from a JSON map.
  ///
  /// This factory constructor is useful for deserializing JSON data into
  /// `SensorData` objects.
  ///
  /// - [json]: A `Map<String, dynamic>` containing the sensor data.
  ///
  /// Returns a new instance of [SensorData].
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      radiationLevel: json['radiation_level'] as String?,
      additionalData: json['additional_data'] != null
          ? Map<String, dynamic>.from(json['additional_data'] as Map)
          : null,
    );
  }

  /// Converts the [SensorData] instance into a JSON map.
  ///
  /// This method is useful for serializing `SensorData` objects into JSON format.
  ///
  /// Returns a `Map<String, dynamic>` representing the sensor data.
  Map<String, dynamic> toJson() {
    return {
      if (radiationLevel != null) 'radiation_level': radiationLevel,
      if (additionalData != null) 'additional_data': additionalData,
    };
  }
}
