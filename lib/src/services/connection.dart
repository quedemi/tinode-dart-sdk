import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tinode/src/models/connection-options.dart';
import 'package:tinode/src/services/logger.dart';
import 'package:tinode/src/services/tools.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

/// This class is responsible for `ws` connection establishments
///
/// Supports `ws` and `wss`
class ConnectionService {
  /// Connection configuration options provided by library user
  final ConnectionOptions _options;

  /// Websocket connection
  WebSocketChannel? _ws;

  /// This callback will be called when connection is opened
  PublishSubject<dynamic> onOpen = PublishSubject<dynamic>();

  /// This callback will be called when connection is closed
  PublishSubject<void> onDisconnect = PublishSubject<void>();

  /// This callback will be called when we receive a message from server
  PublishSubject<String> onMessage = PublishSubject<String>();

  late LoggerService _loggerService;

  bool _connecting = false;

  /// Connection options is required. Defining callbacks is not necessary
  ConnectionService(this._options) {
    _loggerService = GetIt.I.get<LoggerService>();
  }

  bool get isConnected {
    return _streamWebsocketSubscription != null;
  }

  StreamSubscription<dynamic>? _streamWebsocketSubscription;

  /// Start opening websocket connection
  Future connect() async {
    _loggerService.log('Connecting to ' + Tools.makeBaseURL(_options));
    if (isConnected) {
      _loggerService.warn('Reconnecting...');
    }
    _connecting = true;
    _ws = IOWebSocketChannel.connect(
      Tools.makeBaseURL(_options),
      connectTimeout: Duration(milliseconds: 5000),
    );
    _connecting = false;
    _loggerService.log('Connected.');
    onOpen.add('Opened');
    _streamWebsocketSubscription = _ws?.stream.listen((message) {
      onMessage.add(message);
    });
  }

  /// Send a message through websocket websocket connection
  void sendText(String str) {
    if (!isConnected || _connecting) {
      throw Exception('Tried sending data but you are not connected yet.');
    }
    _ws?.sink.add(str);
  }

  /// Close current websocket connection
  Future<void> disconnect() async {
    await _ws?.sink.close(status.goingAway);
    await _streamWebsocketSubscription?.asFuture();
    _streamWebsocketSubscription = null;
    onDisconnect.add(null);
    _connecting = false;
    _loggerService.log('Disconnected.');
  }

  /// Send network probe to check if connection is indeed live
  void probe() {
    return sendText('1');
  }
}
