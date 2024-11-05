import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    /// Reference to the WatchOSMethodChannelHandler to manage WatchOS Method Channel communication.
    private var watchOSMethodChannelHandler: WatchOSMethodChannelHandler?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Flutter's root view controller
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not type FlutterViewController")
        }
        
        // Create the MethodChannel for WatchOS communication
        let watchChannel = FlutterMethodChannel(name: "watchOS_communication", binaryMessenger: controller.binaryMessenger)
        
        // Initialize the WatchOSMethodChannelHandler with the created channel
        watchOSMethodChannelHandler = WatchOSMethodChannelHandler(channel: watchChannel)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
