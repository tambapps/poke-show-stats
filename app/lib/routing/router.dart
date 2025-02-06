import '../ui/screen/about/about_viewmodel.dart';

import '../ui/screen/about/about_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/screen/home/home_screen.dart';
import '../ui/screen/home/home_viewmodel.dart';
import './routes.dart';
import '../ui/screen/teamlytics/teamlytics_viewmodel.dart';
import '../ui/core/themes/dimens.dart';
import '../ui/screen/teamlytics/teamlytics_screen.dart';

// router bug when app ran from IDE on refresh, it always redirects to default route, but not when ran from terminal
// https://github.com/flutter/flutter/issues/114597
GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomeScreen(
          isMobile: Dimens.of(context).isMobile,
        viewModel: context.read(),
      ),
    ),
    GoRoute(
      path: Routes.teamlytic,
      builder: (context, state) {
        final String saveName = state.uri.queryParameters[Routes.saveNameQueryParam] ?? "default";

        return TeamlyticsScreen(
          isMobile: Dimens.of(context).isMobile,
          viewModel: TeamlyticsViewModel(pokemonResourceService: context.read(), saveService: context.read()),
            saveName: saveName
        );
      },
        redirect: (context, state) {
          // Check if the query parameter 'saveName' is present
          final bool hasSaveName = state.uri.queryParameters.containsKey(Routes.saveNameQueryParam);

          // If 'saveName' is missing, redirect to home
          if (!hasSaveName) {
            return '/';
          }

          // Otherwise, allow navigation as is
          return null;
        }
    ),
    GoRoute(
      path: Routes.about,
      builder: (context, state) => AboutScreen(
        viewModel: AboutViewModel(pokemonResourceService: context.read()),
      ),
    )
  ],
);

