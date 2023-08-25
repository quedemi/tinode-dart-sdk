class TinodeException implements Exception {
  final String message;
  final int code;
  TinodeException({
    required this.message,
    required this.code,
  });

  @override
  String toString() {
    return 'TinodeException $message (${code.toString()})';
  }
}
