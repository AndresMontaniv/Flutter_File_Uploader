import 'package:go_router/go_router.dart';

import '../presentation.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'visualize/:id',
          name: FilePreviewScreen.name,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            final filename = state.uri.queryParameters['filename'] ?? 'no_name.txt';
            final fileurl = state.uri.queryParameters['fileurl'];
            return FilePreviewScreen(
              fileId: id!,
              filename: filename,
              fileUrl: fileurl,
            );
          },
        ),
      ],
    ),
  ],
);
