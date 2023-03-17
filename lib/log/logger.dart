// Package imports:
import 'package:simple_logger/simple_logger.dart';

/// エラーハンドリングや、設定値を見るために導入
///
/// Level.〇〇のレベルを変更すると見えるダイアログが変わる。
final logger = SimpleLogger()
  ..setLevel(
    Level.WARNING,
    // Todo リリースビルドではfalseにすること
    includeCallerInfo: true,
  );
