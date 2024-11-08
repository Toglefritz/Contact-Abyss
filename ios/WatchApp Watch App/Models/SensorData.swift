import Foundation

/// A class representing sensor data associated with a game node.
///
/// `SensorData` includes various environmental readings and status indicators
/// that influence the player's decisions and the game's progression.
class SensorData {
    /// The current radiation level detected, represented as a string descriptor.
    ///
    /// Examples include "Low", "Moderate", "High", etc.
    let radiationLevel: String?
    
    /// Additional sensor readings or environmental features.
    ///
    /// This dictionary can include various other sensor data points as needed.
    let additionalData: [String: Any]?
    
    /// Creates a new instance of `SensorData`.
    ///
    /// - Parameters:
    ///   - radiationLevel: Optional radiation level descriptor.
    ///   - additionalData: Optional dictionary of additional sensor data.
    init(radiationLevel: String?, additionalData: [String: Any]?) {
        self.radiationLevel = radiationLevel
        self.additionalData = additionalData
    }
    
    /// Creates a `SensorData` instance from a JSON dictionary.
    ///
    /// - Parameter json: A `[String: Any]` dictionary containing the sensor data.
    convenience init?(json: [String: Any]) {
        // Extract `radiationLevel` as a `String?`
        let radiationLevel = json["radiation_level"] as? String
        
        // Extract `additionalData` as `[String: Any]?`
        let additionalData = json["additional_data"] as? [String: Any]
        
        // Initialize using the primary initializer
        self.init(radiationLevel: radiationLevel, additionalData: additionalData)
    }
    
    /// Converts the `SensorData` instance into a JSON dictionary.
    ///
    /// - Returns: A `[String: Any]` dictionary representing the sensor data.
    func toJson() -> [String: Any] {
        var json = [String: Any]()
        
        if let radiationLevel = radiationLevel {
            json["radiation_level"] = radiationLevel
        }
        
        if let additionalData = additionalData {
            json["additional_data"] = additionalData
        }
        
        return json
    }
}
