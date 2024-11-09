import Flutter
import Foundation

/// `WatchOSMethodChannelHandler` manages Method Channel calls specifically related
/// to WatchOS communication. It delegates message sending and receiving to
/// `WatchConnectivityHandler`.
class WatchOSMethodChannelHandler {
    // MARK: - Properties
    
    /// The Flutter `MethodChannel` used for WatchOS communication.
    private let methodChannel: FlutterMethodChannel
    
    /// Reference to the `WatchConnectivityHandler` singleton.
    private let connectivityHandler = WatchConnectivityHandler.shared
    
    // MARK: - Initializer
    
    /// Initializes the handler with the specified Flutter `MethodChannel`.
    ///
    /// - Parameter channel: The `FlutterMethodChannel` dedicated to WatchOS communication.
    init(channel: FlutterMethodChannel) {
        self.methodChannel = channel
        setupMethodCallHandler()
        connectivityHandler.setMethodChannel(channel: methodChannel)
    }
    
    // MARK: - Method Call Handling
    
    /// Sets up the Method Channel call handler to manage incoming calls from Flutter.
    private func setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else {
                result(FlutterError(code: "HANDLER_DEALLOCATED", message: "WatchOSMethodChannelHandler was deallocated", details: nil))
                return
            }
            
            switch call.method {
            case "sendMessage":
                self.handleSendMessage(call: call, result: result)
            case "sendMessageWithReply":
                self.handleSendMessageWithReply(call: call, result: result)
            case "transferUserInfo":
                self.handleTransferUserInfo(call: call, result: result)
            case "transferFile":
                self.handleTransferFile(call: call, result: result)
            case "updateApplicationContext":
                self.handleUpdateApplicationContext(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - Handler Methods
    
    /// Handles the `sendMessage` Method Channel call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` containing method name and arguments.
    ///   - result: The `FlutterResult` callback to return the result.
    private func handleSendMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected message as dictionary", details: nil))
            return
        }
        
        connectivityHandler.sendMessageToWatch(args) { sendResult in
            switch sendResult {
            case .success():
                result(nil) // Indicate success
            case .failure(let error):
                // Map the error to a FlutterError
                let flutterError = FlutterError(code: "MESSAGE_SENDING_FAILED",
                                                message: error.localizedDescription,
                                                details: nil)
                result(flutterError)
            }
        }
    }
    
    /// Handles the `sendMessageWithReply` Method Channel call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` containing method name and arguments.
    ///   - result: The `FlutterResult` callback to return the result.
    private func handleSendMessageWithReply(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected message as dictionary", details: nil))
            return
        }
        
        connectivityHandler.sendMessageToWatch(args, replyHandler: { reply in
            // On success, return the reply to Flutter
            result(reply)
        }) { sendResult in
            switch sendResult {
            case .success(_):
                // The reply has already been handled in replyHandler
                break
            case .failure(let error):
                // Map the error to a FlutterError
                let flutterError = FlutterError(code: "MESSAGE_SENDING_FAILED",
                                                message: error.localizedDescription,
                                                details: nil)
                result(flutterError)
            }
        }
    }
    
    /// Handles the `transferUserInfo` Method Channel call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` containing method name and arguments.
    ///   - result: The `FlutterResult` callback to return the result.
    private func handleTransferUserInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userInfo = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected userInfo as dictionary", details: nil))
            return
        }
        
        connectivityHandler.transferUserInfo(userInfo)
        result(nil) // Indicate success
    }
    
    /// Handles the `transferFile` Method Channel call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` containing method name and arguments.
    ///   - result: The `FlutterResult` callback to return the result.
    private func handleTransferFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String,
              let fileURL = URL(string: filePath) else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected filePath as string", details: nil))
            return
        }
        
        let metadata = args["metadata"] as? [String: Any]
        connectivityHandler.transferFile(fileURL, metadata: metadata)
        result(nil) // Indicate success
    }
    
    /// Handles the `updateApplicationContext` Method Channel call from Flutter.
    ///
    /// - Parameters:
    ///   - call: The `FlutterMethodCall` containing method name and arguments.
    ///   - result: The `FlutterResult` callback to return the result.
    private func handleUpdateApplicationContext(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let context = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected context as dictionary", details: nil))
            return
        }
        
        connectivityHandler.updateApplicationContext(context)
        result(nil) // Indicate success
    }
}
