import 'dart:convert';

import 'package:discord_interactions/discord_interactions.dart';
import 'package:discord_interactions_test/interactions_test_server.dart';
import 'package:functions_framework/functions_framework.dart';
import 'package:discord_interactions_test/credentials.dart';
import 'package:shelf/shelf.dart';

final validator = InteractionValidator(
  applicationPublicKey: Credentials.applicationPublicKey,
);

final interactionsTestServer = InteractionsTestServer();

@CloudFunction()
Future<Response> function(Request request) async {
  final path = request.requestedUri.path;

  switch (path) {
    case '/start-server':
      await interactionsTestServer.start();
      return Response.ok('Server started');
    case '/stop-server':
      await interactionsTestServer.stop();
      return Response.ok('Server stopped');
  }

  // This is an interaction from Discord
  final body = await request.readAsString();
  final valid = validator.validate(headers: request.headers, body: body);
  if (!valid) {
    return Response(401, body: 'invalid request signature');
  }
  final interaction = Interaction.fromJson(jsonDecode(body));
  if (interaction.type == InteractionType.ping) {
    return Response.ok(
      jsonEncode(InteractionResponse(type: InteractionCallbackType.pong)),
    );
  }

  // TODO: Send message to clients

  return Response.ok(path);
}
