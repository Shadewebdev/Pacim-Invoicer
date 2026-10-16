import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_router.dart';
import '../theme/app_color_tokens.dart';

class StatusBar extends ConsumerWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final message = ref.watch(statusBarMessageProvider);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: tokens.chrome,
        border: Border(top: BorderSide(color: tokens.rule)),
      ),
      child: Text(
        message ?? '',
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: tokens.ink),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
