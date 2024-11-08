import Foundation

/// A class representing a single node in the "Contact Abyss" game.
///
/// Each `GameNode` contains the narrative text, sensor data, available choices, battery power changes,
/// and information about whether the node signifies the end of the game.
class GameNode {
    /// A unique identifier for the node.
    let id: String
    
    /// The narrative text displayed to the player at this node.
    let storyText: String
    
    /// Optional sensor data associated with this node.
    let sensorData: SensorData?
    
    /// A list of choices available to the player at this node.
    let choices: [Choice]
    
    /// The change in battery power resulting from the player's decision at this node.
    let batteryChange: Int?
    
    /// Indicates whether this node is an ending point of the game.
    let isEnd: Bool
    
    /// Determines if the game outcome is a win, loss, or neutral.
    /// A `GameOutcome` will only be available for ending nodes.
    let outcome: GameOutcome?
    
    /// Creates a new instance of `GameNode`.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the node.
    ///   - storyText: The narrative text displayed to the player.
    ///   - sensorData: Optional sensor data related to the node.
    ///   - choices: A list of available choices at this node.
    ///   - batteryChange: Optional change in battery power.
    ///   - isEnd: Flag indicating if this node is an ending point.
    ///   - outcome: Optional game outcome associated with this node.
    init(
        id: String,
        storyText: String,
        sensorData: SensorData?,
        choices: [Choice],
        batteryChange: Int?,
        isEnd: Bool = false,
        outcome: GameOutcome? = nil
    ) {
        self.id = id
        self.storyText = storyText
        self.sensorData = sensorData
        self.choices = choices
        self.batteryChange = batteryChange
        self.isEnd = isEnd
        self.outcome = outcome
    }
    
    /// Creates a `GameNode` instance from a JSON dictionary.
    ///
    /// - Parameter json: A `[String: Any]` dictionary containing the node's data.
    /// - Returns: A new instance of `GameNode` or `nil` if the dictionary is invalid.
    convenience init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
              let storyText = json["story_text"] as? String else {
            return nil
        }
        
        let sensorData = (json["sensor_data"] as? [String: Any]).flatMap { SensorData(json: $0) }
        
        let choices = (json["choices"] as? [[String: Any]] ?? []).compactMap { Choice(json: $0) }
        
        let batteryChange = json["battery_change"] as? Int
        
        let isEnd = json["is_end"] as? Bool ?? false
        
        let outcomeString = json["outcome"] as? String
        let outcome = outcomeString.flatMap { GameOutcome(rawValue: $0) }
        
        self.init(
            id: id,
            storyText: storyText,
            sensorData: sensorData,
            choices: choices,
            batteryChange: batteryChange,
            isEnd: isEnd,
            outcome: outcome
        )
    }
    
    /// Converts the `GameNode` instance into a JSON dictionary.
    ///
    /// - Returns: A `[String: Any]` dictionary representing the node's data.
    func toJson() -> [String: Any] {
        var json: [String: Any] = [
            "id": id,
            "story_text": storyText,
            "choices": choices.map { $0.toJson() },
            "is_end": isEnd
        ]
        
        if let sensorData = sensorData {
            json["sensor_data"] = sensorData.toJson()
        }
        
        if let batteryChange = batteryChange {
            json["battery_change"] = batteryChange
        }
        
        if let outcome = outcome {
            json["outcome"] = outcome.rawValue
        }
        
        return json
    }
}
