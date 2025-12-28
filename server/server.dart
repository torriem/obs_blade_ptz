import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

void main(List<String> args) async {
  // Get the directory where the executable is located
  final exePath = Platform.script.toFilePath();
  final exeDir = File(exePath).parent.path;
  final webDir = Directory('$exeDir/web');

  // Check if web directory exists
  if (!webDir.existsSync()) {
    print('Error: web directory not found at ${webDir.path}');
    print('Make sure to copy the build/web folder next to this executable.');
    exit(1);
  }

  // Create a handler for serving static files
  final handler = Cascade()
      .add(createStaticHandler(
        webDir.path,
        defaultDocument: 'index.html',
        listDirectories: false,
      ))
      .handler;

  // Add middleware for logging
  final loggedHandler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(handler);

  // Start the server
  final port = int.tryParse(args.isNotEmpty ? args[0] : '8080') ?? 8080;
  final server = await shelf_io.serve(loggedHandler, 'localhost', port);

  print('Serving Flutter web app at http://${server.address.host}:${server.port}');
  print('Press Ctrl+C to stop the server');
}
