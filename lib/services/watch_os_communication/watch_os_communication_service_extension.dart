import 'package:contact_abyss/services/game_service/game_data_service.dart';
import 'package:contact_abyss/services/game_service/models/game_node.dart';
import 'package:contact_abyss/services/watch_os_communication/watch_os_communication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An extension on the [WatchOSCommunicationService] class that provides application-specific methods for interacting
/// with the WatchOS companion app.
///
/// The [WatchOSCommunicationService] class offers a generic interface for managing communication between the Flutter
/// app and the WatchOS app via Method Channel calls. It defines fundamental methods for sending messages, handling
/// responses, and managing asynchronous data transfers, making it suitable for use across multiple projects. These
/// generic capabilities include:
///
/// - Sending messages to the WatchOS app with or without expecting a reply.
/// - Transferring user information or files to the WatchOS app asynchronously.
/// - Updating the application context for the WatchOS app.
/// - Listening for messages or reachability changes from the WatchOS app.
///
/// While the [WatchOSCommunicationService] serves as the foundational communication layer, this
/// extension—[WatchOSCommunicationServiceExtension]—adds methods tailored to the specific requirements of the current
/// application.
///
/// ### Purpose of the Extension
///
/// By separating the generic communication logic from application-specific logic, this architecture allows the
/// [WatchOSCommunicationService] to be easily reused in other projects. Each project can implement its own extension
/// to the [WatchOSCommunicationService] with methods customized to its unique requirements. This design promotes code
/// reusability, maintainability, and modularity.
///
/// ### Benefits of This Design
///
/// 1. **Reusability**: The [WatchOSCommunicationService] can be reused across multiple projects without modification.
///    Each project can implement its own extension to handle application-specific logic.
///
/// 2. **Modularity**: By isolating application-specific methods in an extension, the core [WatchOSCommunicationService]
///    remains focused on generic communication tasks. This reduces complexity and makes the overall system easier to
///    understand and maintain.
///
/// 3. **Scalability**: As the application evolves, new methods can be added to the extension without impacting the
///    core [WatchOSCommunicationService].
///
/// 4. **Ease of Testing**: Generic communication methods and application-specific logic can be tested independently,
///    enabling more targeted unit and integration tests.
extension WatchOSCommunicationServiceExtension on WatchOSCommunicationService {
  /// Handles the application-specific logic for handling a message from the WatchOS app, sent via the iOS app through
  /// a Method Channel call.
  Future<Map<String, dynamic>?> handleMethodCall(MethodCall call) async {
    // Safely cast arguments to Map<String, dynamic>
    final Map<String, dynamic> message = Map<String, dynamic>.from(call.arguments as Map<Object?, Object?>);

    switch (call.method) {
      // The WatchOS app has sent a message to the Flutter app.
      case 'receivedMessageFromWatch':
        debugPrint('Received message from WatchOS: $message');

        // Process the message and prepare a response
        final Map<String, dynamic> response = await _processMessageAndGetResponse(message);

        // Return a response to the iOS side.
        return response;

      // The method call is not recognized.
      default:
        debugPrint('Unhandled method call: ${call.method}');

        return null;
    }
  }

  /// Processes the incoming message and returns a response.
  ///
  /// This method is called when the Flutter app receives a message from the WatchOS app. It processes the message and
  /// generates a response based on the message content. The response is then sent back to the WatchOS app.
  Future<Map<String, dynamic>> _processMessageAndGetResponse(Map<String, dynamic> message) async {
    // The WatchOS app has requested the current game node.
    if (message['action'] == 'requestCurrentGameNode') {
      final GameDataService gameDataService = GameDataService();

      final GameNode? gameNode = gameDataService.currentNode.value;

      // If there is a current game node, return it in the response.
      if (gameNode != null) {
        return {
          'success': true,
          'gameNode': gameNode.toJson(),
        };
      }
      // If there is no current game node, return a null value, which indicates that a game has not been started.
      else {
        return {
          'success': true,
          'gameNode': null,
        };
      }
    }

    // The WatchOS app has requested a new game.
    else if (message['action'] == 'startNewGame') {
      // If the game data has not already been loaded, load it.
      if (!GameDataService().isGameLoaded) {
        try {
          await GameDataService().loadGameData();
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to load game data: $e',
          };
        }
      }

      // Reset the game in case it was already in progress.
      GameDataService().startNewGame();

      // Return the initial game node to the WatchOS app.
      final GameNode initialNode = GameDataService().currentNode.value!;

      return {
        'success': true,
        'gameNode': initialNode.toJson(),
      };
    }

    // Handle other actions
    return {
      'success': false,
      'message': "Unhandled action: ${message['action']}",
    };
  }

  /// Sends a [GameNode] to the WatchOS app to keep both apps in sync.
  ///
  /// This method serializes the [GameNode] to a JSON-compatible map and sends it to the WatchOS app via the iOS app
  /// using a Method Channel call.
  Future<void> sendGameNode(GameNode gameNode) async {
    final Map<String, dynamic> message = {
      'action': 'updateGameNode',
      'gameNode': gameNode.toJson(),
    };

    try {
      // Invoke the method on the MethodChannel to send the message to the iOS app
      final Map<String, dynamic>? result = await sendMessageWithReply(message);

      debugPrint('Successfully sent GameNode to WatchOS: ${gameNode.id}');

      if (result != null && result['success'] == true) {
        debugPrint('WatchOS app acknowledged the GameNode.');
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to send GameNode to WatchOS: ${e.message}');

      rethrow;
    }
  }
}
