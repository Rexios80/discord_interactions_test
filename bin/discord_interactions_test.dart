import 'package:functions_framework/serve.dart';
import 'package:discord_interactions_test/functions.dart' as functions;

Future<void> main(List<String> args) async {
  await serve(args, _nameToFunctionTarget);
}

FunctionTarget? _nameToFunctionTarget(String name) {
  switch (name) {
    case 'function':
      return FunctionTarget.http(functions.function);
    default:
      return null;
  }
}
