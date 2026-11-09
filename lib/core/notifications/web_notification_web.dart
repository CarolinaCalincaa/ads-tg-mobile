// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Solicita permissão para notificações na Web Notification API.
Future<bool> requestWebNotificationPermission() async {
  try {
    if (!html.Notification.supported) return false;
    final String permission = await html.Notification.requestPermission();
    return permission == 'granted';
  } catch (_) {
    return false;
  }
}

/// Dispara a notificação nativa do navegador na Web.
Future<bool> showWebNotification(String title, String body) async {
  try {
    if (!html.Notification.supported) return false;

    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body, icon: 'favicon.png');
      return true;
    } else if (html.Notification.permission != 'denied') {
      final String perm = await html.Notification.requestPermission();
      if (perm == 'granted') {
        html.Notification(title, body: body, icon: 'favicon.png');
        return true;
      }
    }
    return false;
  } catch (_) {
    return false;
  }
}
