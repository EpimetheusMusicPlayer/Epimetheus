import 'package:logger/logger.dart';
import 'package:logger_flutter/logger_flutter.dart';

Logger createLogger(String tag) {
  return Logger(
    output: const AppOutput(Level.debug),
    level: Level.verbose,
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        printTime: true,
        colors: true,
      ),
      debug: '$tag: DEBUG',
      verbose: '$tag: VERBOSE',
      wtf: '$tag: WTF',
      info: '$tag: INFO',
      warning: '$tag: WARNING',
      error: '$tag: ERROR',
    ),
  );
}

class AppOutput implements LogOutput {
  final Level consoleOutputLevel;

  const AppOutput(this.consoleOutputLevel);

  @override
  void init() {}

  @override
  void output(OutputEvent event) {
    if (event.level.index >= consoleOutputLevel.index) {
      event.lines.forEach(print);
    }
    LogConsole.add(event);
  }

  @override
  void destroy() {}
}
