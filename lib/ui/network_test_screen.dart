import 'dart:async';
import 'package:flutter/material.dart';
import '../networking/local_link.dart';

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});
  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  final _link = LocalLink();
  final _ip = TextEditingController();
  final _port = TextEditingController(text: '4040');
  final _message = TextEditingController();
  final _log = <String>[];
  List<String> _addresses = [];
  StreamSubscription<String>? _subscription;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _subscription = _link.events.listen((event) {
      if (!mounted) return;
      setState(() {
        _log.insert(0, event);
        if (_log.length > 100) _log.removeLast();
      });
    });
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int _readPort() {
    final port = int.tryParse(_port.text);
    if (port == null || port < 1 || port > 65535) {
      throw const FormatException('Port must be between 1 and 65535.');
    }
    return port;
  }

  Future<void> _refresh() async {
    final addresses = await LocalLink.addresses();
    if (mounted) setState(() => _addresses = addresses);
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_link.dispose());
    _ip.dispose();
    _port.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ashta Chemma')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Offline connection test',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text(
            'Connect both phones to the same Wi-Fi or phone hotspot. Mobile data can stay off.',
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              _link.status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextField(
            controller: _port,
            enabled: !_busy && !_link.hosting && !_link.connected,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Port'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy || _link.hosting || _link.connected
                ? null
                : () => _perform(() async {
                    await _link.host(port: _readPort());
                    await _refresh();
                  }),
            child: const Text('Start host on this phone'),
          ),
          if (_link.hosting)
            Text(
              'Listening on port ${_link.port}. Share a Wi-Fi/hotspot IP below.',
            ),
          TextButton(
            onPressed: _busy ? null : () => _perform(_refresh),
            child: const Text('Refresh local IP addresses'),
          ),
          for (final address in _addresses) SelectableText(address),
          if (_link.hosting && _addresses.isEmpty)
            const Text(
              'No IPv4 address found. Enable hotspot/Wi-Fi, then refresh.',
            ),
          if (_addresses.isNotEmpty)
            const Text(
              'Multiple addresses? Use the interface belonging to your shared Wi-Fi/hotspot. Try another listed IP if connection fails.',
            ),
          const Divider(height: 32),
          TextField(
            controller: _ip,
            enabled: !_busy && !_link.hosting && !_link.connected,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Host IPv4 address',
              hintText: 'Enter the IP shown on the host',
            ),
          ),
          FilledButton.tonal(
            onPressed: _busy || _link.hosting || _link.connected
                ? null
                : () => _perform(() => _link.join(_ip.text, _readPort())),
            child: const Text('Connect / reconnect to host'),
          ),
          OutlinedButton(
            onPressed: _busy ? null : () => _perform(_link.stop),
            child: const Text('Stop / disconnect'),
          ),
          const Divider(height: 32),
          TextField(
            controller: _message,
            maxLength: 500,
            enabled: _link.connected,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          FilledButton(
            onPressed: _busy || !_link.connected
                ? null
                : () => _perform(() async {
                    _link.send(_message.text);
                    _message.clear();
                  }),
            child: const Text('Send message'),
          ),
          const Text(
            'Activity (newest first). Sent means queued locally; check Received on the other phone.',
          ),
          for (final line in _log)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(line),
            ),
        ],
      ),
    ),
  );
}
