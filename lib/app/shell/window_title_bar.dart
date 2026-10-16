import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../theme/app_color_tokens.dart';

/// Custom Windows title bar; the native one is hidden in `main()`.
class WindowTitleBar extends StatelessWidget {
  const WindowTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorTokens>()!;
    final brightness = Theme.of(context).brightness;
    return Container(
      height: 32,
      color: tokens.chrome,
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.receipt_long, size: 16, color: tokens.action),
                  const SizedBox(width: 8),
                  Text(
                    'Pacim Invoicer',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: tokens.ink),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 138,
            child: Row(
              children: [
                Expanded(
                  child: WindowCaptionButton.minimize(
                    brightness: brightness,
                    onPressed: windowManager.minimize,
                  ),
                ),
                Expanded(
                  child: WindowCaptionButton.maximize(
                    brightness: brightness,
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        await windowManager.unmaximize();
                      } else {
                        await windowManager.maximize();
                      }
                    },
                  ),
                ),
                Expanded(
                  child: WindowCaptionButton.close(
                    brightness: brightness,
                    onPressed: windowManager.close,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
