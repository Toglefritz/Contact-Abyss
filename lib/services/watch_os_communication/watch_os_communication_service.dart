import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// `WatchOSCommunicationService` facilitates seamless communication between the Flutter application and the WatchOS
/// companion app by leveraging Flutter's Method Channels and Dart Streams.
///
/// **Purpose:**
/// This service serves as the bridge for sending and receiving data between the Flutter app and the WatchOS
/// app. It encapsulates the complexities of Method Channel communication, providing a straightforward API
/// for developers to interact with the native iOS side without delving into platform-specific implementations.
///
/// **Singleton Pattern:**
/// `WatchOSCommunicationService` is implemented as a singleton to ensure that only one instance exists
/// throughout the application's lifecycle. This design choice guarantees a consistent state and prevents
/// potential conflicts or redundant instances that could arise from multiple initializations. By using a
/// singleton, any part of the Flutter app can access the communication service without the need to pass
/// around instances, promoting ease of use and maintainability.
///
/// **Dual Purpose:**
/// 1. **Sending Method Channel Calls to the Swift Side:**
///    - **Functionality:** Provides methods to send various types of messages and commands to the native iOS
///      side. These include sending simple messages, transferring user information, transferring files,
///      and updating the application context.
///    - **Usage:** Developers can invoke these methods to communicate with the WatchOS app, enabling actions
///      such as updating watch data, initiating processes on the watch, or sending commands based on user
///      interactions within the Flutter app.
///
/// 2. **Setting Up Streams for Incoming Messages and Reachability Changes:**
///    - **Functionality:** Establishes Dart Streams that listen for incoming Method Channel calls from the
///      native iOS side. Specifically, it listens for:
///      - `receivedMessageFromWatch`: Indicates that a new message has been received from the WatchOS app.
///      - `watchReachabilityChanged`: Notifies about changes in the connectivity status of the WatchOS app.
///    - **Usage:** Widgets, controllers, or any other part of the Flutter app can subscribe to these streams to
///      react to real-time events. For instance, a controller can update the UI when a new message is received,
///      or handle connectivity changes by enabling/disabling certain features.
///
/// **Initialization and Lifecycle:**
/// - **Initialization:** The `initialize()` method must be called early in the app's lifecycle (e.g., in the `main()`
///   function or within an `initState` method) to set up the Method Call Handler and start listening for incoming
///   events. Initiating the service early ensures that the iOS app does not miss messages sent from the WatchOS app.
/// - **Disposal:** The `dispose()` method should be invoked when the service is no longer needed (e.g., when the app
///   is terminated) to close the StreamControllers and prevent memory leaks.
///
/// ## Communication Categories: Synchronous vs Asynchronous Communication
/// The `WatchOSCommunicationService` class offers methods categorized based on the nature of communication:
///
/// 1. **Synchronous Communication**:
///    These methods are used for real-time interactions with the WatchOS app when it is currently reachable. They
///    require an immediate connection and are best suited for scenarios where immediate data transfer and response are
///    necessary.
///    - `sendMessageToWatch`: Sends a message to the WatchOS app without expecting an immediate reply.
///    - `sendMessageWithReply`: Sends a message and awaits an immediate response from the WatchOS app.
///
/// 2. **Asynchronous Communication**:
///    These methods facilitate background data synchronization. They queue data to be sent to the WatchOS app, ensuring
///    that the information is delivered the next time the WatchOS app is activated or becomes reachable. This approach
///    is ideal for non-urgent data that doesn't require immediate processing.
///    - `transferUserInfo`: Transfers user information to the WatchOS app for background processing.
///    - `transferFile`: Transfers files to the WatchOS app to be received when it's next active.
///    - `updateApplicationContext`: Updates the application context, allowing the WatchOS app to receive the latest
///       state when it becomes active.
///
///
/// **Usage Example:**
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'watch_os_communication_service.dart';
///
/// void main() {
///   WidgetsFlutterBinding.ensureInitialized();
///   WatchOSCommunicationService().initialize();
///   runApp(App());
/// }
///
/// class App extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'Flutter WatchOS Communication',
///       home: HomePage(),
///     );
///   }
/// }
///
/// class HomePage extends StatefulWidget {
///   @override
///   _HomePageState createState() => _HomePageState();
/// }
///
/// class _HomePageState extends State<HomePage> {
///   final WatchOSCommunicationService _watchService = WatchOSCommunicationService();
///   StreamSubscription<Map<String, dynamic>>? _messageSubscription;
///   StreamSubscription<bool>? _reachabilitySubscription;
///
///   @override
///   void initState() {
///     super.initState();
///     // Subscribe to incoming messages from WatchOS app
///     _messageSubscription = _watchService.receivedMessageStream.listen(_handleMessageReceived);
///
///     // Subscribe to reachability changes
///     _reachabilitySubscription = _watchService.watchReachabilityStream.listen(_handleReachabilityChanged);
///   }
///
///   void _handleMessageReceived(Map<String, dynamic> message) {
///     // Handle the received message
///     print('Message from WatchOS: $message');
///     // Perform actions based on the message
///   }
///
///   void _handleReachabilityChanged(bool isReachable) {
///     // Handle reachability changes
///     print('WatchOS is reachable: $isReachable');
///     // Update UI or state based on reachability
///   }
///
///   @override
///   void dispose() {
///     // Cancel subscriptions to prevent memory leaks
///     _messageSubscription?.cancel();
///     _reachabilitySubscription?.cancel();
///     _watchService.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text('Flutter WatchOS Communication'),
///       ),
///       body: Center(
///         child: Text('Listening for WatchOS messages...'),
///       ),
///     );
///   }
/// }
/// ```
class WatchOSCommunicationService {
  /// Factory constructor to return the singleton instance of the [WatchOSCommunicationService].
  factory WatchOSCommunicationService() => _instance;

  /// Private constructor to prevent instantiation of this class.
  WatchOSCommunicationService._privateConstructor();

  /// The singleton instance of the [WatchOSCommunicationService].
  static final WatchOSCommunicationService _instance = WatchOSCommunicationService._privateConstructor();

  /// The [MethodChannel] used to communicate with the native iOS code.
  static const MethodChannel _channel = MethodChannel('watchOS_communication');

  /// A [StreamController] for messages received from the WatchOS app.
  final StreamController<Map<String, dynamic>> _messageController = StreamController<Map<String, dynamic>>.broadcast();

  /// A [StreamController] for reachability changes of the WatchOS app.
  final StreamController<bool> _reachabilityController = StreamController<bool>.broadcast();

  /// Stream of messages received from the WatchOS app.
  Stream<Map<String, dynamic>> get receivedMessageStream => _messageController.stream;

  /// Stream of reachability changes of the WatchOS app.
  Stream<bool> get watchReachabilityStream => _reachabilityController.stream;

  /// Initializes the Method Call Handler to listen for incoming messages from iOS.
  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Sends a message to the WatchOS app without expecting a reply.
  ///
  /// This method facilitates real-time communication with the WatchOS app. It requires that the WatchOS app is
  /// currently reachable. If the WatchOS app is not reachable, the Method Channel call will fail, and a
  /// `PlatformException` will be thrown.
  Future<void> sendMessageToWatch(Map<String, dynamic> message) async {
    try {
      await _channel.invokeMethod('sendMessage', message);
    } on PlatformException catch (e) {
      debugPrint('Sending message to watch failed with error, ${e.message}');

      rethrow;
    }
  }

  /// Sends a message to the WatchOS app and awaits a response.
  ///
  /// This method enables synchronous communication by sending a message to the WatchOS app and awaiting an immediate
  /// response. It requires that the WatchOS app is currently reachable. If the WatchOS app is not reachable, the
  /// Method Channel call will fail, and a `PlatformException` will be thrown.
  Future<Map<String, dynamic>?> sendMessageWithReply(Map<String, dynamic> message) async {
    try {
      final Map<String, dynamic>? reply = await _channel.invokeMapMethod<String, dynamic>('sendMessageWithReply', message);

      return reply;
    } on PlatformException catch (e) {
      debugPrint('Sending message to watch with reply failed with error, ${e.message}');

      rethrow;
    }
  }

  /// Transfers user info to the WatchOS app asynchronously.
  ///
  /// This method is used to send key-value pairs containing information about the user to the WatchOS companion app.
  /// This method sends information asynchronously and does not wait for a response from the WatchOS app. Therefore, it
  /// is best used for non-urgent data that does not require immediate confirmation, receipt, or action.
  Future<void> transferUserInfo(Map<String, dynamic> userInfo) async {
    try {
      await _channel.invokeMethod('transferUserInfo', userInfo);
    } on PlatformException catch (e) {
      debugPrint('Transferring user data to watched failed with exception, ${e.message}');
    }
  }

  /// Transfers a file to the WatchOS app asynchronously.
  ///
  /// This method allows the Flutter application to transfer files to its WatchOS companion app without requiring
  /// the WatchOS app to be reachable at the time of invocation. The file transfer is handled asynchronously,
  /// ensuring that the file is delivered in the background when the WatchOS app becomes reachable or is next
  /// activated.
  Future<void> transferFile(String filePath, {Map<String, dynamic>? metadata}) async {
    try {
      await _channel.invokeMethod('transferFile', {
        'filePath': filePath,
        'metadata': metadata,
      });
    } on PlatformException catch (e) {
      debugPrint('Transferring file to watch failed with exception, ${e.message}');
    }
  }

  /// Updates the application context on the WatchOS app.
  ///
  /// This method is used to send key-value pairs containing information about the user to the WatchOS companion app.
  /// This method sends information asynchronously and does not wait for a response from the WatchOS app. Therefore, it
  /// is best used for non-urgent data that does not require immediate confirmation, receipt, or action. The next time
  /// the WatchOS app becomes active, it will receive the updated application context.
  Future<void> updateApplicationContext(Map<String, dynamic> context) async {
    try {
      await _channel.invokeMethod('updateApplicationContext', context);
    } on PlatformException catch (e) {
      debugPrint('Updating watch application context failed with exception, ${e.message}');
    }
  }

  /// Handles incoming method calls from the native iOS side.
  ///
  /// The Swift side can send two different Method Channel calls to the Dart side resulting from activity by the
  /// WatchOS companion app: `receivedMessageFromWatch` and `watchReachabilityChanged`. This method processes these
  /// calls and notifies the appropriate StreamControllers to broadcast the received messages or reachability changes.
  /// Using StreamControllers allows other parts of the Flutter app to listen for these events and respond accordingly.
  ///
  /// As with all Stream-based operations, listeners must be sure to dispose of their subscriptions to prevent memory
  /// leaks when they are no longer needed.
  Future<void> _handleMethodCall(MethodCall call) async {
    // Make sure that the arguments are not null and are of the correct type.
    if (call.arguments == null || call.arguments is! Map) {
      debugPrint('Received method call with null arguments');

      return;
    }

    // Cast the arguments to a Map.
    final Map<String, dynamic> arguments = call.arguments as Map<String, dynamic>;

    switch (call.method) {
      // The WatchOS app has sent a message to the Flutter app.
      case 'receivedMessageFromWatch':
        final Map<String, dynamic> message = Map<String, dynamic>.from(call.arguments as Map<dynamic, dynamic>);
        _messageController.add(message);

      // The WatchOS app has sent a reachability change notification.
      case 'watchReachabilityChanged':
        if (arguments.containsKey('isReachable') && arguments['isReachable'] is bool) {
          final bool isReachable = arguments['isReachable'] as bool;
          _reachabilityController.add(isReachable);
        } else {
          debugPrint('watchReachabilityChanged called with invalid arguments: $arguments');
        }

      // The method call is not recognized.
      default:
        debugPrint('Unhandled method call: ${call.method}');
        break;
    }
  }

  /// Disposes the StreamControllers to prevent memory leaks.
  void dispose() {
    _messageController.close();
    _reachabilityController.close();
  }
}