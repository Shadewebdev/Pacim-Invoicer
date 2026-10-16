import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

const double minimumPageZoom = 0.5;
const double maximumPageZoom = 2.0;
const double pageZoomStep = 0.1;

/// How far the A4 page is magnified, shared by every open editor.
class PageZoomNotifier extends Notifier<double> {
  @override
  double build() => 1.0;

  void setZoom(double zoom) {
    state = math.min(maximumPageZoom, math.max(minimumPageZoom, zoom));
  }

  void zoomBySteps(int steps) {
    // Rounded to a step multiple so repeated wheel ticks do not drift.
    final stepped = ((state + steps * pageZoomStep) * 10).round() / 10;
    setZoom(stepped);
  }
}

final pageZoomProvider = NotifierProvider<PageZoomNotifier, double>(
  PageZoomNotifier.new,
);
