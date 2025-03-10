import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:my_log/my_log.dart';
import 'package:test/test.dart';

void main() {
  mainMyLog();
}

/// Remind comment on tested function: // #TESTED
void mainMyLog() {
  group('MyLog', () {
    test('setUp', () {
      final MyLog myLog = MyLog();

      myLog.setUp(printTime: false);
      expect(
        myLog.logger.toString(),
        Logger(
          printer: PrettyPrinter(
            printEmojis: false,
          ),
          filter: kReleaseMode ? PermissiveFilter() : DevelopmentFilter(),
        ).toString(),
      );
    });
  });
}
