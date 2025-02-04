

abstract final class Routes {
  static const home = '/';
  static const about = '/about';
  static const teamlytic = '/teamlytic';

  static String teamlyticsRoute(String saveName) {
    return "$teamlytic?$saveNameQueryParam=${Uri.encodeComponent(saveName)}";
  }
  static const saveNameQueryParam = 'saveName';
}