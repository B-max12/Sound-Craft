/// Platform-conditional database connection factory.
library;

export 'connection_stub.dart' if (dart.library.html) 'connection_web.dart';
