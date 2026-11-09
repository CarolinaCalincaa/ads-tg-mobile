/// Stub para plataformas não-web (Android / iOS / Desktop / Testes).
Future<bool> requestWebNotificationPermission() async => false;

Future<bool> showWebNotification(String title, String body) async => false;
