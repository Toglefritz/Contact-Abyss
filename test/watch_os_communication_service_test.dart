import 'package:contact_abyss/services/watch_os_communication/watch_os_communication_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// This file provides unit tests for the WatchOSCommunicationService class. These unit tests verify the correct
/// functionality of the WatchOSCommunicationService class by mocking the platform channel communication and
/// testing the expected behavior of the service methods.
///
/// This test can be run using the following command:
///
/// ```sh
/// flutter test test/watch_os_communication_service_test.dart
/// ```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WatchOSCommunicationService', () {
    const MethodChannel channel = MethodChannel('watchOS_communication');

    final List<MethodCall> log = <MethodCall>[];
    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (MethodCall methodCall) async {
        log.add(methodCall);
        // Define mock responses based on the method name
        switch (methodCall.method) {
          case 'sendMessage':
            // Simulate success
            return null;
          case 'sendMessageWithReply':
            // Simulate a reply
            return {'status': 'success'};
          case 'transferUserInfo':
            return null;
          case 'transferFile':
            return null;
          case 'updateApplicationContext':
            return null;
          default:
            throw PlatformException(
              code: 'UNAVAILABLE',
              message: 'Method not implemented',
            );
        }
      });
    });

    test('sendMessageToWatch sends correct method call and handles success', () async {
      final WatchOSCommunicationService service = WatchOSCommunicationService();
      await service.sendMessageToWatch({'key': 'value'});

      expect(log, hasLength(1));
      expect(log.first.method, 'sendMessage');
      expect(log.first.arguments, {'key': 'value'});
    });

    test('sendMessageToWatch handles failure when watch is not reachable', () async {
      // Update the mock handler to throw an exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (MethodCall methodCall) async {
        if (methodCall.method == 'sendMessage') {
          throw PlatformException(code: 'MESSAGE_SENDING_FAILED', message: 'Watch not reachable');
        }

        return null;
      });

      final WatchOSCommunicationService service = WatchOSCommunicationService();
      expect(() async => service.sendMessageToWatch({'key': 'value'}), throwsA(isA<PlatformException>()));
    });

    test('sendMessageWithReply sends correct method call and handles reply', () async {
      final WatchOSCommunicationService service = WatchOSCommunicationService();
      final Map<String, dynamic>? reply = await service.sendMessageWithReply({'command': 'test'});

      expect(log, hasLength(1));
      expect(log.first.method, 'sendMessageWithReply');
      expect(log.first.arguments, {'command': 'test'});
      expect(reply, {'status': 'success'});
    });

    test('sendMessageWithReply handles failure when watch is not reachable by throwing PlatformException', () async {
      // Arrange: Set up the mock MethodChannel to throw a PlatformException when 'sendMessageWithReply' is called
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (MethodCall methodCall) async {
        if (methodCall.method == 'sendMessageWithReply') {
          throw PlatformException(
            code: 'MESSAGE_SENDING_FAILED',
            message: 'Watch not reachable',
          );
        }
        return null;
      });

      final WatchOSCommunicationService service = WatchOSCommunicationService();

      // Act & Assert: Expect the sendMessageWithReply method to throw a PlatformException
      expect(
        () async => service.sendMessageWithReply({'command': 'test'}),
        throwsA(
          isA<PlatformException>()
              .having(
                (e) => e.code,
                'code',
                'MESSAGE_SENDING_FAILED',
              )
              .having(
                (e) => e.message,
                'message',
                'Watch not reachable',
              ),
        ),
      );
    });

    test('transferFile sends correct method call', () async {
      final WatchOSCommunicationService service = WatchOSCommunicationService();
      await service.transferFile('/path/to/file', metadata: {'description': 'Test file'});

      expect(log, hasLength(1));
      expect(log.first.method, 'transferFile');
      expect(log.first.arguments, {
        'filePath': '/path/to/file',
        'metadata': {'description': 'Test file'},
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });
  });
}
