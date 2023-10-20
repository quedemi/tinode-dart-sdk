import 'package:get_it/get_it.dart';
import 'package:tinode/src/services/configuration.dart';

class LoggerService {
  late ConfigService _configService;

  LoggerService() {
    _configService = GetIt.I.get<ConfigService>();
  }

  void error(String value) {
    _configService.logger?.onError(value);
  }

  void log(String value) {
    _configService.logger?.onLog(value);
  }

  void warn(String value) {
    _configService.logger?.onWarn(value);
  }
}

class Logger {
  final void Function(String message) onError;
  final void Function(String message) onLog;
  final void Function(String message) onWarn;
  Logger({
    required this.onError,
    required this.onLog,
    required this.onWarn,
  });
}
