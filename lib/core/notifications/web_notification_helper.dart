import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_web.dart' as impl;

Future<bool> requestWebNotificationPermission() =>
    impl.requestWebNotificationPermission();

Future<bool> showWebNotification(String title, String body) =>
    impl.showWebNotification(title, body);
