import 'dart:math';

double convertBytesToGBs(final int bytes, {int precision = 2}) {
  return double.parse(
    (bytes / (1024 * 1024 * 1024)).toStringAsFixed(precision),
  );
}

final storageUnits = ["bytes", "KB", "MB", "GB"];

String convertBytesToReadableFormat(int bytes) {
  int storageUnitIndex = 0;
  while (bytes >= 1024 && storageUnitIndex < storageUnits.length - 1) {
    storageUnitIndex++;
    bytes = (bytes / 1024).round();
  }
  return "$bytes ${storageUnits[storageUnitIndex]}";
}

String formatBytes(int bytes, [int decimals = 2]) {
  if (bytes == 0) return '0 bytes';
  const k = 1024;
  final int dm = decimals < 0 ? 0 : decimals;
  final int i = (log(bytes) / log(k)).floor();
  return '${(bytes / pow(k, i)).toStringAsFixed(dm)} ${storageUnits[i]}';
}
