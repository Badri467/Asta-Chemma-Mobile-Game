import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A small, two-phone transport experiment, independent of Flutter widgets.
class LocalLink {
  final _events = StreamController<String>.broadcast();
  Stream<String> get events => _events.stream;
  HttpServer? _server;
  WebSocket? _socket;
  HttpClient? _connectingClient;
  int _generation = 0;
  bool _disposed = false;
  String status = 'Disconnected';
  int? get port => _server?.port;
  bool get hosting => _server != null;
  bool get connected => _socket?.readyState == WebSocket.open;

  void _emit(String text) {
    if (!_disposed) _events.add(text);
  }

  void _status(String value) {
    status = value;
    _emit(value);
  }

  static Future<List<String>> addresses() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    return [
      for (final i in interfaces)
        for (final a in i.addresses) '${i.name}: ${a.address}',
    ];
  }

  Future<void> host({int port = 4040}) async {
    await stop();
    final generation = _generation;
    try {
      final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      if (generation != _generation || _disposed) {
        await server.close(force: true);
        return;
      }
      _server = server;
      _status('Hosting — waiting for a guest');
      server.listen(
        (request) async {
          if (request.uri.path != '/link' ||
              !WebSocketTransformer.isUpgradeRequest(request)) {
            request.response.statusCode = HttpStatus.badRequest;
            await request.response.close();
            return;
          }
          if (_socket != null) {
            request.response.statusCode = HttpStatus.serviceUnavailable;
            await request.response.close();
            return;
          }
          try {
            final socket = await WebSocketTransformer.upgrade(request);
            if (generation != _generation || _disposed || _socket != null) {
              await socket.close();
              return;
            }
            _attach(socket, generation);
          } catch (_) {
            if (generation == _generation) {
              _emit('Guest handshake failed. Try again.');
            }
          }
        },
        onError: (Object error) {
          if (generation == _generation) _emit('Server error: $error');
        },
      );
    } catch (error) {
      if (generation == _generation) _status('Could not host: $error');
      rethrow;
    }
  }

  Future<void> join(String address, int port) async {
    final ip = InternetAddress.tryParse(address.trim());
    if (ip == null ||
        ip.type != InternetAddressType.IPv4 ||
        port < 1 ||
        port > 65535) {
      throw const FormatException(
        'Enter the host IPv4 address and a port from 1 to 65535.',
      );
    }
    await stop();
    final generation = _generation;
    _status('Connecting…');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    _connectingClient = client;
    try {
      // Closing this HttpClient also cancels an outstanding handshake on timeout.
      final socket = await WebSocket.connect(
        'ws://${ip.address}:$port/link',
        customClient: client,
      ).timeout(const Duration(seconds: 10));
      if (generation != _generation || _disposed) {
        await socket.close();
        return;
      }
      _attach(socket, generation);
    } catch (error) {
      client.close(force: true);
      if (generation == _generation) {
        _status('Connection failed. Check Wi-Fi, IP and port, then retry.');
      }
      rethrow;
    } finally {
      if (identical(_connectingClient, client)) _connectingClient = null;
    }
  }

  void _attach(WebSocket socket, int generation) {
    _socket = socket;
    socket.pingInterval = const Duration(seconds: 3);
    _status(hosting ? 'Connected — host' : 'Connected — guest');
    void lost() {
      if (generation != _generation || !identical(_socket, socket)) return;
      _socket = null;
      _status(
        hosting
            ? 'Guest disconnected — waiting for reconnect'
            : 'Disconnected — reconnect when ready',
      );
    }

    socket.listen(
      (data) {
        try {
          if (data is! String || data.length > 4096) {
            throw const FormatException();
          }
          final message = jsonDecode(data);
          if (message is! Map ||
              message['v'] != 1 ||
              message['type'] != 'text' ||
              message['text'] is! String ||
              (message['text'] as String).length > 500 ||
              (message['text'] as String).trim().isEmpty) {
            throw const FormatException();
          }
          _emit('Received: ${message['text']}');
        } catch (_) {
          _emit('Ignored an invalid message');
        }
      },
      onDone: lost,
      onError: (Object error) {
        lost();
      },
      cancelOnError: true,
    );
  }

  void send(String text) {
    text = text.trim();
    if (!connected) throw StateError('Connect both phones first.');
    if (text.isEmpty || text.length > 500) {
      throw const FormatException('Use 1–500 characters.');
    }
    _socket!.add(jsonEncode({'v': 1, 'type': 'text', 'text': text}));
    _emit('Sent: $text');
  }

  Future<void> stop() async {
    _generation++;
    _connectingClient?.close(force: true);
    _connectingClient = null;
    final socket = _socket;
    final server = _server;
    _socket = null;
    _server = null;
    if (socket != null) {
      unawaited(
        socket.close(WebSocketStatus.goingAway).catchError((Object _) {}),
      );
    }
    if (server != null) await server.close(force: true);
    _status('Disconnected');
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
    await _events.close();
  }
}
