import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/connection.dart';

/// Web specific websocket implementation
WebSocketChannel createWebSocket(Connection connection,
    [Duration pingInterval = const Duration(seconds: 3)]) {
  String protocol =
      connection.isDomain == null || !connection.isDomain! ? 'ws://' : '';

  final uri = Uri.parse(
      '$protocol${connection.host}${connection.port != null ? (":${connection.port}") : ""}');

  // Note: HtmlWebSocketChannel doesn't support pingInterval
  return HtmlWebSocketChannel.connect(uri);
}
