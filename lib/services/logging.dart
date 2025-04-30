// lib/utils/logging.dart
import 'package:logger/logger.dart';

class LogHelper {
  // Membuat instance logger
  static var logger = Logger(
    printer: PrettyPrinter(), // Agar output log lebih rapi dan mudah dibaca
  );

  // Fungsi untuk log informasi
  static void logInfo(String message) {
    logger.i(message);
  }

  // Fungsi untuk log peringatan
  static void logWarning(String message) {
    logger.w(message);
  }

  // Fungsi untuk log kesalahan
  static void logError(String message) {
    logger.e(message);
  }

  // Fungsi untuk log debug
  static void logDebug(String message) {
    logger.d(message);
  }
}
