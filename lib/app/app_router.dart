import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/document_type.dart';
import 'shell/app_shell.dart';
import '../features/settings/settings_page.dart';
import '../features/document_list/document_list_page.dart';
import '../features/document_editor/document_editor_page.dart';

const _defaultLocation = '/quotations';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: _defaultLocation,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => _defaultLocation),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/documents/:documentId',
            builder: (context, state) => DocumentEditorPage(
              documentId: state.pathParameters['documentId']!,
            ),
          ),
          GoRoute(
            path: '/:typeSegment',
            redirect: (context, state) {
              final segment = state.pathParameters['typeSegment']!;
              final isKnown = DocumentType.values.any(
                (type) => type.routeSegment == segment,
              );
              return isKnown ? null : _defaultLocation;
            },
            builder: (context, state) => DocumentListPage(
              documentType: DocumentType.fromRouteSegment(
                state.pathParameters['typeSegment']!,
              ),
            ),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
