// Web connection: drift WasmDatabase (see web/ assets: sqlite3.wasm + drift_worker.js).
// Browser storage is sandboxed and may be evicted — surfaced honestly in UI.
import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

DatabaseConnection openPlatformConnection() {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: 'soundcraft',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
