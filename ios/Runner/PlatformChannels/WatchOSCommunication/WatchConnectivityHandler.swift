import WatchConnectivity
import Flutter

/// `WatchConnectivityHandler` is a singleton class responsible for managing
/// communication between the iOS Flutter app and the WatchOS companion app.
/// It utilizes Apple's Watch Connectivity framework to send and receive messages,
/// and bridges these messages to Flutter via a `MethodChannel`.
class WatchConnectivityHandler: NSObject, WCSessionDelegate {
    
    // MARK: - Properties
    
    /// The shared instance of `WatchConnectivityHandler` to ensure a single
    /// point of communication throughout the app lifecycle.
    static let shared = WatchConnectivityHandler()
    
    /// The Flutter `MethodChannel` used to communicate with the Dart side of the app.
    /// This channel is set by the AppDelegate and is used to send messages received
    /// from the WatchOS app to Flutter.
    private var channel: FlutterMethodChannel?
    
    /// A flag indicating whether the WCSession has been activated.
    private var isSessionActivated = false
    
    // MARK: - Initializer
    
    /// A private initializer to enforce the singleton pattern.
    /// It sets up the Watch Connectivity session upon initialization.
    private override init() {
        super.init()
        setupSession()
    }
    
    // MARK: - Session Setup
    
    /// Configures and activates the `WCSession` if supported.
    /// Sets the `WatchConnectivityHandler` as the session's delegate to handle
    /// incoming messages and session state changes.
    private func setupSession() {
        guard WCSession.isSupported() else {
            print("Watch Connectivity is not supported on this device.")
            return
        }
        
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    // MARK: - Method Channel Configuration
    
    /// Associates the provided `FlutterMethodChannel` with this handler.
    /// This allows the handler to send messages to the Flutter side when
    /// messages are received from the WatchOS app.
    ///
    /// - Parameter channel: The `FlutterMethodChannel` to be set for communication.
    func setMethodChannel(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    // MARK: - Message Sending
    
    /// Sends a message to the WatchOS app without expecting a reply.
    ///
    /// - Parameters:
    ///   - message: A dictionary containing the data to send.
    ///   - completion: A closure to handle the result.
    func sendMessageToWatch(_ message: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard WCSession.default.isReachable else {
            print("iOS app is not reachable. Cannot send message to WatchOS app.")
            completion(.failure(WatchConnectivityError.watchNotReachable))
            return
        }
        
        WCSession.default.sendMessage(message, replyHandler: { response in
            // Handle any response from WatchOS app if needed
            print("Received reply from WatchOS app: \(response)")
            completion(.success(()))
        }, errorHandler: { error in
            print("Error sending message to WatchOS app: \(error.localizedDescription)")
            completion(.failure(error))
        })
    }
    
    /// Sends a message to the connected WatchOS app and handles the reply.
    /// This is useful when a response from the WatchOS app is expected.
    ///
    /// - Parameters:
    ///   - message: A dictionary containing the message data to send.
    ///   - replyHandler: A closure to handle the reply from the WatchOS app.
    ///   - completion: A closure that takes a `Result<[String: Any], Error>` indicating success or failure.
    func sendMessageToWatch(_ message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(message, replyHandler: { reply in
                // Pass the reply back through the replyHandler and completion as success.
                replyHandler(reply)
                completion(.success(reply))
            }) { error in
                // Handle any errors that occur during message sending.
                print("Failed to send message to Watch: \(error.localizedDescription)")
                completion(.failure(WatchConnectivityError.messageSendingFailed(error.localizedDescription)))
            }
        } else {
            print("Watch is not reachable. Message not sent.")
            completion(.failure(WatchConnectivityError.watchNotReachable))
        }
    }
    
    // MARK: - WCSessionDelegate Methods
    
    /// Called when the session activation state changes.
    /// Useful for handling different session states if needed.
    ///
    /// - Parameters:
    ///   - session: The `WCSession` object.
    ///   - activationState: The new activation state of the session.
    ///   - error: An error object if activation failed, otherwise `nil`.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        isSessionActivated = true
        print("WCSession activated with state: \(activationState.rawValue)")
    }
    
    /// Handles the receipt of a message from the WatchOS app without a reply handler.
    /// When a message is received, it invokes a method on the Flutter side
    /// to pass the message data to Dart.
    ///
    /// - Parameters:
    ///   - session: The `WCSession` object.
    ///   - message: The message dictionary sent from the WatchOS app.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message from Watch: \(message)")
        // Ensure that the channel is set before invoking methods.
        guard let channel = channel else {
            print("Flutter MethodChannel is not set. Unable to forward message.")
            return
        }
        // Invoke a method on the Flutter side with the received message.
        channel.invokeMethod("receivedMessageFromWatch", arguments: message)
    }
    
    /// Handles the receipt of a message from the WatchOS app with a reply handler.
    /// This allows for sending a response back to the WatchOS app.
    ///
    /// - Parameters:
    ///   - session: The `WCSession` object.
    ///   - message: The message dictionary sent from the WatchOS app.
    ///   - replyHandler: A closure to send a reply back to the WatchOS app.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Received message with reply handler from Watch: \(message)")
        
        // The maximum length of time to wait for for Dart/Flutter side to respond.
        let flutterResponseTimeout: TimeInterval = 5.0 // 5 seconds
        
        // Forward the message to Flutter via MethodChannel and await response
        guard let channel = channel else {
            print("Flutter MethodChannel is not set. Unable to forward message.")
            // Respond with an error to WatchOS app
            let errorResponse: [String: Any] = [
                "error": "MethodChannel not initialized"
            ]
            replyHandler(errorResponse)
            
            return
        }
        
        // Define a flag to ensure replyHandler is called only once
        var isReplied = false
        
        // Set up a timeout mechanism using DispatchWorkItem
        let timeoutWorkItem = DispatchWorkItem {
            if !isReplied {
                isReplied = true
                print("Flutter did not respond in time. Sending timeout error to WatchOS app.")
                let timeoutResponse: [String: Any] = [
                    "error": "Flutter response timed out"
                ]
                replyHandler(timeoutResponse)
            }
        }
        
        // Schedule the timeout work item
        DispatchQueue.main.asyncAfter(deadline: .now() + flutterResponseTimeout, execute: timeoutWorkItem)
        
        // Forward the message to Flutter on the main thread
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            
            channel.invokeMethod("receivedMessageFromWatch", arguments: message) { result in
                // Cancel the timeout if Flutter responds in time
                timeoutWorkItem.cancel()
                
                // Ensure that replyHandler is not called multiple times
                guard !isReplied else {
                    print("Timeout already occurred. Ignoring Flutter's response.")
                    return
                }
                isReplied = true
                
                if let response = result as? [String: Any] {
                    // Check if the response contains an "error" key
                    if let firstKey = response.keys.first, firstKey == "error" {
                        print("Error received from Dart/Flutter side: \(response[firstKey] ?? "Unknown error")")
                        let error = NSError(domain: "CommunicationService", code: 1, userInfo: [
                            NSLocalizedDescriptionKey: response[firstKey] as? String ?? "An unknown error occurred."
                        ])
                        // Handle the error by passing it back to the WatchOS app
                        let errorResponse: [String: Any] = [
                            "error": response[firstKey] as? String ?? "Unknown error"
                        ]
                        replyHandler(errorResponse)
                    } else {
                        // Successfully received a valid response from Flutter
                        print("Received response from Flutter: \(response)")
                        replyHandler(response)
                    }
                } else {
                    // Handle the case where result is `nil` or an unexpected type
                    print("Invalid or nil response from Flutter.")
                    let errorResponse: [String: Any] = [
                        "error": "Invalid response from Flutter"
                    ]
                    replyHandler(errorResponse)
                }
            }
        }
    }
    
    /// Called when the reachability of the paired device changes.
    /// Can be used to update UI or handle connectivity changes as needed.
    ///
    /// - Parameter session: The `WCSession` object.
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Session reachability changed: \(session.isReachable)")
        // Optionally notify Flutter about the change in reachability.
        channel?.invokeMethod("watchReachabilityChanged", arguments: ["isReachable": session.isReachable])
    }
    
    /// Called when the paired Watch becomes inactive.
    /// Typically used to handle session deactivation.
    ///
    /// - Parameter session: The `WCSession` object.
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession did become inactive.")
    }
    
    /// Called when the paired Watch deactivates the session.
    /// Can be used to clean up resources or reset the session if necessary.
    ///
    /// - Parameter session: The `WCSession` object.
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession did deactivate.")
        // Reactivate the session if needed.
        session.activate()
    }
    
    /// Handle any changes to the watch's state.
    /// This method can be used to respond to changes such as the watch being turned on or off.
    ///
    /// - Parameter session: The `WCSession` object.
    func sessionWatchStateDidChange(_ session: WCSession) {
        // Implement if needed.
        print("Watch state changed.")
    }
    
    // MARK: - Additional Helper Methods
    
    /// Checks if the Watch is currently reachable.
    ///
    /// - Returns: A Boolean indicating the reachability of the Watch.
    func isWatchReachable() -> Bool {
        return WCSession.default.isReachable
    }
    
    /// Retrieves the current paired Watch's information.
    ///
    /// - Returns: A dictionary containing the Watch's state information.
    func getWatchInfo() -> [String: Any] {
        let isInstalled = WCSession.default.isWatchAppInstalled
        let isReachable = WCSession.default.isReachable
        return ["isInstalled": isInstalled, "isReachable": isReachable]
    }
    
    /// Sends user info to the WatchOS app.
    /// User info is delivered in the background and is best for non-urgent data.
    ///
    /// - Parameter userInfo: A dictionary containing the user info to send.
    func transferUserInfo(_ userInfo: [String: Any]) {
        WCSession.default.transferUserInfo(userInfo)
    }
    
    /// Sends a file to the WatchOS app.
    /// This is useful for transferring larger files.
    ///
    /// - Parameters:
    ///   - fileURL: The local URL of the file to transfer.
    ///   - metadata: Optional metadata associated with the file.
    func transferFile(_ fileURL: URL, metadata: [String: Any]? = nil) {
        WCSession.default.transferFile(fileURL, metadata: metadata)
    }
    
    /// Updates the application context.
    /// Application context is delivered as soon as possible and is best for the latest app state.
    ///
    /// - Parameter context: A dictionary representing the current app state.
    func updateApplicationContext(_ context: [String: Any]) {
        do {
            try WCSession.default.updateApplicationContext(context)
        } catch {
            print("Failed to update application context: \(error.localizedDescription)")
        }
    }
}
