import Foundation

/// A class representing a choice available to the player at a specific game node.
///
/// Each `Choice` includes the text displayed to the player and the target node's
/// unique identifier that the game will navigate to upon selection.
class Choice {
    /// The text of the choice presented to the player.
    let choiceText: String
    
    /// The unique identifier of the target `GameNode` this choice leads to.
    let target: String
    
    /// Creates a new instance of `Choice`.
    ///
    /// - Parameters:
    ///   - choiceText: The text displayed for this choice.
    ///   - target: The ID of the node that this choice navigates to.
    init(choiceText: String, target: String) {
        self.choiceText = choiceText
        self.target = target
    }
    
    /// Creates a `Choice` instance from a JSON dictionary.
    ///
    /// This convenience initializer is useful for deserializing JSON data into
    /// `Choice` objects.
    ///
    /// - Parameter json: A `[String: Any]` dictionary containing the choice's data.
    /// - Returns: A new instance of `Choice` or `nil` if the dictionary is invalid.
    convenience init?(json: [String: Any]) {
        // Extract `choiceText` and `target` values from the JSON dictionary.
        guard let choiceText = json["choice_text"] as? String,
              let target = json["target"] as? String else {
            return nil // Return nil if required fields are missing or invalid.
        }
        
        // Initialize using the primary initializer.
        self.init(choiceText: choiceText, target: target)
    }
    
    /// Converts the `Choice` instance into a JSON dictionary.
    ///
    /// This method is useful for serializing `Choice` objects into JSON format.
    ///
    /// - Returns: A `[String: Any]` dictionary representing the choice's data.
    func toJson() -> [String: Any] {
        return [
            "choice_text": choiceText,
            "target": target
        ]
    }
}
