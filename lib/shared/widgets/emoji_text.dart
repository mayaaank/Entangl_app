import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// Renders user text so emoji use the system color-emoji face
/// while the rest of the string keeps the app type system.
class EmojiText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const EmojiText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  static final _emoji = RegExp(
    r'(?:\p{Extended_Pictographic}(?:\uFE0F|\u200D\p{Extended_Pictographic})*)',
    unicode: true,
  );

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    if (!_emoji.hasMatch(text)) {
      return Text(
        text,
        style: base,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in _emoji.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: AppTextStyles.emojiOnly(size: base.fontSize ?? 16),
      ));
      cursor = match.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
