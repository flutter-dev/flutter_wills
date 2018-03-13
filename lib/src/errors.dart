class _BaseException implements Exception {
  final dynamic reason;

  const _BaseException(this.reason);

  String toString() => '${runtimeType}.reason: $reason';
}

class WillsActionInterruptException extends _BaseException {
  const WillsActionInterruptException([reason]): super(reason);
}

class WillsActionExistsException extends _BaseException {
  const WillsActionExistsException([reason]): super(reason);
}