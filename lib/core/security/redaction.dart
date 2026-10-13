class Redaction {
  const Redaction._();

  static const redacted = '[redacted]';

  static String sensitive(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '';
    return redacted;
  }

  static String inline(String text) {
    return text
        .replaceAll(RegExp(r'sk-[A-Za-z0-9_-]{12,}'), redacted)
        .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9._-]+'), 'Bearer $redacted')
        .replaceAll(RegExp(r'gh[pousr]_[A-Za-z0-9_]{12,}'), redacted);
  }
}
