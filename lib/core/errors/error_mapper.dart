import 'app_error.dart';
import '../security/redaction.dart';

class ErrorMapper {
  const ErrorMapper._();

  static AppError fromObject(Object error) {
    final redacted = Redaction.inline(error.toString());
    return AppError(redacted);
  }
}
