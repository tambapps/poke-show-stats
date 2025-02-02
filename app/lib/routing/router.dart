import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import './routes.dart';
import '../ui/teamlytics/teamlytics_viewmodel.dart';
import '../ui/core/themes/dimens.dart';
import '../ui/teamlytics/teamlytics_screen.dart';

GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => TeamlyticsScreen(
          isMobile: Dimens.of(context).isMobile,
        viewModel: TeamlyticsViewModel(pokemonResourceService: context.read(), saveService: context.read()),
      ),
    ),
  ],
);

