class SngplException implements Exception {
  const SngplException(this.message);
  final String message;

  @override
  String toString() => message;
}
