import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Native (Android/iOS/desktop) connection: background isolate SQLite.
/// Sqlite3 libraries come from sqlite3_flutter_libs.
Future<DatabaseConnection> openPlatformConnection() async {
  final dir = await getApplicationSupportDirectory();
  final file = p.join(dir.path, 'soundcraft.sqlite3');
  return DatabaseConnection(NativeDatabase.createInBackground(File(file)));
}
