import 'dart:async';
import 'dart:io';
import 'package:ashta_chemma/networking/local_link.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> waitFor(bool Function() predicate) async {
  for (var i = 0; i < 100; i++) {
    if (predicate()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  throw TimeoutException('Expected connection state not reached');
}

void main() {
  test(
    'real sockets exchange messages, detect disconnect and reconnect',
    () async {
      final host = LocalLink();
      final guest = LocalLink();
      addTearDown(host.dispose);
      addTearDown(guest.dispose);
      await host.host(port: 0);
      await guest.join('127.0.0.1', host.port!);
      await waitFor(() => host.connected);
      final received = host.events.firstWhere(
        (e) => e == 'Received: hello host',
      );
      guest.send('hello host');
      expect(
        await received.timeout(const Duration(seconds: 2)),
        'Received: hello host',
      );
      final reply = guest.events.firstWhere(
        (e) => e == 'Received: hello guest',
      );
      host.send('hello guest');
      expect(
        await reply.timeout(const Duration(seconds: 2)),
        'Received: hello guest',
      );
      await guest.stop();
      await waitFor(() => !host.connected);
      expect(host.hosting, isTrue);
      await guest.join('127.0.0.1', host.port!);
      await waitFor(() => host.connected);
      await host.stop();
      await waitFor(() => !guest.connected);
    },
  );

  test(
    'rejects invalid address and unavailable port without staying connected',
    () async {
      final guest = LocalLink();
      addTearDown(guest.dispose);
      await expectLater(guest.join('not an IP', 4040), throwsFormatException);
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final unusedPort = server.port;
      await server.close();
      await expectLater(
        guest.join('127.0.0.1', unusedPort),
        throwsA(isA<Exception>()),
      );
      expect(guest.connected, isFalse);
      expect(guest.status, contains('failed'));
      expect(() => guest.send('hello'), throwsStateError);
    },
  );

  test(
    'malformed messages are ignored and a second guest is rejected',
    () async {
      final host = LocalLink();
      addTearDown(host.dispose);
      await host.host(port: 0);
      final socket = await WebSocket.connect(
        'ws://127.0.0.1:${host.port}/link',
      );
      addTearDown(() => socket.close());
      await waitFor(() => host.connected);
      final invalid = host.events.firstWhere(
        (e) => e == 'Ignored an invalid message',
      );
      socket.add('{broken');
      await invalid.timeout(const Duration(seconds: 2));
      await expectLater(
        WebSocket.connect('ws://127.0.0.1:${host.port}/link'),
        throwsA(isA<WebSocketException>()),
      );
      expect(() => host.send(' '), throwsFormatException);
      expect(host.connected, isTrue);
    },
  );
}
