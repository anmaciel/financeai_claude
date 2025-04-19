// util/log_util.dart
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Função para criar logs personalizados no FinanceAI.
///
/// [message] é a mensagem a ser registrada no log.
/// [level] define a severidade do log (`info`, `warning`, ou `error`).
///
void debugLog({
  required String message,
  String level = 'info',
}) {
  if (kDebugMode) {
    final int severity;

    // Define o nível de severidade com base no tipo de log
    switch (level.toLowerCase()) {
      case 'warning':
        severity = 900;
        break;
      case 'error':
        severity = 1000;
        break;
      default:
        severity = 800; // Nível padrão para info
    }

    developer.log(
      message,
      level: severity,
      name: 'FINANCEAI - $level'.toUpperCase(), // Rótulo para o tipo de log
    );
  }
}

class LogUtil {
  static void log({
    required String message,
    String level = 'info',
  }) {
    if (kDebugMode) {
      final int severity;

      switch (level.toLowerCase()) {
        case 'warning':
          severity = 900;
          break;
        case 'error':
          severity = 1000;
          break;
        default:
          severity = 800;
      }

      developer.log(
        message,
        level: severity,
        name: 'FINANCEAI - $level'.toUpperCase(),
      );
    }
  }
}
