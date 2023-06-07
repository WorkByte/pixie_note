import 'dart:io' show Directory, Platform;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixie_note/sticky_note/sticky_note_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WindowManager.instance.setTitle('Pixie Note');
    WindowManager.instance.setSize(Size(320, 600));
    WindowManager.instance.setMinimumSize(Size(320, 600));
    WindowManager.instance
        .setMaximumSize(const Size(double.infinity, double.infinity));
    WindowManager.instance.setAlignment(Alignment.topRight);
  }

  Directory appDir = await getApplicationSupportDirectory();
  String dataDirPath = '${appDir.path}/pixie_note';
  Directory dataDir = Directory(dataDirPath);

  if (!await dataDir.exists()) {
    await dataDir.create(recursive: true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixie Note',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: StickyNoteProvider(),
    );
  }
}
