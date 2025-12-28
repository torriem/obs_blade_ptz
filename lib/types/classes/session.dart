import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../models/connection.dart';

class Session {
  WebSocketChannel socket;
  Stream? socketStream;
  Connection connection;

  Session(this.socket, this.connection);
}
