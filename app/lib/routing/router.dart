import 'package:app2/routing/routes.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/core/themes/dimens.dart';
import '../ui/home/home_screen.dart';



GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomeScreen(
          isMobile: Dimens.of(context).isMobile,
        viewModel: HomeViewModel(pokemonResourceService: context.read(), saveService: context.read(), pokeApi: context.read()),
      ),
    ),
  ],
);

