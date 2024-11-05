import 'package:contact_abyss/contact_abyss_app.dart';
import 'package:contact_abyss/services/watch_os_communication/watch_os_communication_service.dart';
import 'package:flutter/material.dart';

/// The main entry point for the Contact Abyss game.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the WatchOSCommunicationService
  WatchOSCommunicationService().initialize();

  runApp(const ContactAbyssApp());
}
