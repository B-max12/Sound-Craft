/// Conditional export: real iframe on web, no-op elsewhere.
library;

export 'web_iframe_stub.dart' if (dart.library.html) 'web_iframe_web.dart';
