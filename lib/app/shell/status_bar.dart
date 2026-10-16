import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_color_tokens.dart';
import 'status_bar_count_provider.dart';
import 'status_bar_message_provider.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final message = ref.watch(statusBarMessageProvider);
    final count = ref.watch(statusBarCountProvider);
    final textStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: tokens.ink);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: tokens.chrome,
        border: Border(top: BorderSide(color: tokens.rule)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message ?? '',
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (count != null) Text(count, style: textStyle),
        ],
      ),
    );
  }
}
