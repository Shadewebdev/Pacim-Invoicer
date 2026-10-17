import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/app_breakpoints.dart';
import '../../../app/theme/app_color_tokens.dart';
import 'document_page_view.dart';
import 'page_zoom_provider.dart';

/// Breathing room around the page inside the canvas, in logical pixels.
const double documentCanvasPadding = 24;

/// Tighter padding on phone-width canvases, where every pixel counts.
const double _compactCanvasPadding = 8;

/// The scrolling, zoomable surface the A4 page sits on.
///
/// The page is laid out at 100% and scaled, so what you see at any zoom is
/// the same layout the PDF prints. Ctrl + mouse wheel changes the zoom.
class DocumentCanvas extends ConsumerWidget {
  const DocumentCanvas({
    required this.documentId,
    required this.onViewportWidthChanged,
    super.key,
  });

  final String documentId;

  /// Reports the canvas width so "Fit width" can compute a zoom.
  final ValueChanged<double> onViewportWidthChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(pageZoomProvider);
    final surface = Theme.of(context).extension<AppColorTokens>()!.surface;

    return LayoutBuilder(
      builder: (context, constraints) {
        onViewportWidthChanged(constraints.maxWidth);
        // Below 600 px the page always scales down to the screen width, even
        // past the zoom floor, rather than needing a sideways scroll.
        final isCompact = constraints.maxWidth < AppBreakpoints.compactMaxWidth;
        final padding = isCompact
            ? _compactCanvasPadding
            : documentCanvasPadding;
        final requestedWidth = DocumentPageView.pageWidth * zoom;
        final scaledWidth = isCompact
            ? math.min(requestedWidth, constraints.maxWidth - 2 * padding)
            : requestedWidth;
        final contentWidth = scaledWidth + 2 * padding;
        return ColoredBox(
          color: surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth > constraints.maxWidth
                  ? contentWidth
                  : constraints.maxWidth,
              child: SingleChildScrollView(
                // Inside the scroll views so it claims the wheel before they do.
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is! PointerScrollEvent) return;
                    if (!HardwareKeyboard.instance.isControlPressed) return;
                    GestureBinding.instance.pointerSignalResolver.register(
                      event,
                      (_) => ref
                          .read(pageZoomProvider.notifier)
                          .zoomBySteps(event.scrollDelta.dy < 0 ? 1 : -1),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Center(
                      child: SizedBox(
                        width: scaledWidth,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          child: DocumentPageView(documentId: documentId),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
