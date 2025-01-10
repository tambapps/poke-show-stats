import 'package:app2/routing/routes.dart';
import 'package:app2/ui/home/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../ui/home/home_screen.dart';



GoRouter router() => GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomeScreen(
        viewModel: HomeViewModel(pokemonImageService: context.read()),
      ),
    ),
  ],
);

