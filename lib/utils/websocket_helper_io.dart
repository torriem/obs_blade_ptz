import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/connection.dart';

/// IO (mobile/desktop) specific websocket implementation
WebSocketChannel createWebSocket(Connection connection,
    [Duration pingInterval = const Duration(seconds: 3)]) {
  String protocol =
      connection.isDomain == null || !connection.isDomain! ? 'ws://' : '';

  final uri = Uri.parse(
      '$protocol${connection.host}${connection.port != null ? (":${connection.port}") : ""}');

  return IOWebSocketChannel.connect(uri, pingInterval: pingInterval);
}
