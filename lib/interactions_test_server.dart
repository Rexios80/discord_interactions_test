import 'dart:io';

import 'package:discord_interactions_test/credentials.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class InteractionsTestServer {
  HttpServer? server;
  WebSocketChannel? channel;

  Future<void> start() async {
    final handler = webSocketHandler((webSocket) => channel = webSocket);

    server = await shelf_io
        .serve(handler, Credentials.cloudRunHost, 8080)
        .then((server) {
      print('Serving at ws://${server.address.host}:${server.port}');
    });
  }

  Future<void> stop() async {
    await server?.close();
  }
}
