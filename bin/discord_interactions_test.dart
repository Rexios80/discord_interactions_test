import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_ws;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:discord_interactions/discord_interactions.dart';

import 'credentials.dart';

final validator = InteractionValidator(
  applicationPublicKey: Credentials.applicationPublicKey,
);

// The local instance of discord_intteractions that is running tests
WebSocketChannel? client;
Stream? clientStream;

void main(List<String> arguments) {
  final app = Router()
    ..post('/rest', handleHttpRequest)
    ..get('/ws', shelf_ws.webSocketHandler(handleWebSocketConnect));

  shelf_io.serve(app, '0.0.0.0', int.parse(Platform.environment['PORT']!));
}

Future<Response> handleHttpRequest(Request request) async {
  final body = await request.readAsString();

  // Validate Interactions headers
  final valid = validator.validate(headers: request.headers, body: body);
  if (!valid) {
    return Response(401, body: 'invalid request signature');
  }

  final interaction = Interaction.fromJson(jsonDecode(body));

  // Respond to pings
  if (interaction.type == InteractionType.ping) {
    return Response.ok(
      jsonEncode(InteractionResponse(type: InteractionCallbackType.pong)),
    );
  }

  // Send the Interaction to the test client
  client?.sink.add(body);

  // Wait for the client to confirm the Interaction was handled
  await clientStream?.first;

  return Response.ok(null);
}

void handleWebSocketConnect(WebSocketChannel socket) {
  client = socket;

  // Convert socket.stream to a boradcast stream
  final socketStreamController = StreamController.broadcast();
  socket.stream.listen(socketStreamController.add);

  clientStream = socketStreamController.stream;
}
