import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serviço gerenciador de Notificações Locais (`RF21`, `ADR-008`).
///
/// Encapsula [FlutterLocalNotificationsPlugin] com inicialização segura e tolerante a falhas
/// em todas as plataformas suportadas (Android, iOS, Web SPA e ambiente de testes).
class LocalNotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Registrador de testes para inspecionar notificações disparadas sem depender de canal de plataforma.
  final List<Map<String, dynamic>> testNotificationLog = <Map<String, dynamic>>[];

  bool get isInitialized => _initialized;

  /// Inicializa o plugin suavemente.
  Future<bool> initialize() async {
    if (_initialized) return true;

    // Em ambiente Web ou testes sem mocks de canais de plataforma nativos
    if (kIsWeb) {
      _initialized = true;
      debugPrint('[LocalNotificationService] Plataforma Web: inicialização suave em modo no-op.');
      return true;
    }

    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? success = await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint(
            '[LocalNotificationService] Resposta de notificação: ${response.payload}',
          );
        },
      );

      _initialized = success ?? false;
      return _initialized;
    } catch (e, stack) {
      debugPrint('[LocalNotificationService] Falha ao inicializar canais nativos: $e\n$stack');
      _initialized = false;
      return false;
    }
  }

  /// Dispara uma notificação imediata de teste para validação pelo usuário (`RF21`).
  Future<void> showTestNotification({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    testNotificationLog.add(<String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (kIsWeb || !_initialized) {
      debugPrint('[LocalNotificationService - InApp/Test] Alerta registrado: $title - $body');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'lembretes_cognitivos',
        'Lembretes de Saúde Cognitiva',
        channelDescription:
            'Alertas locais periódicos de hidratação, pausa ativa, sono e fechamento reflexivo',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('[LocalNotificationService] Erro ao exibir notificação local: $e');
    }
  }

  /// Cancela uma notificação agendada ou ativa pelo ID.
  Future<void> cancelReminder(int id) async {
    testNotificationLog.removeWhere((item) => item['id'] == id);
    if (kIsWeb) return;
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('[LocalNotificationService] Erro ao cancelar notificação $id: $e');
    }
  }

  /// Cancela todas as notificações ativas.
  Future<void> cancelAll() async {
    testNotificationLog.clear();
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[LocalNotificationService] Erro ao cancelar todas as notificações: $e');
    }
  }
}

final Provider<LocalNotificationService> localNotificationServiceProvider =
    Provider<LocalNotificationService>((Ref ref) {
  final LocalNotificationService service = LocalNotificationService();
  service.initialize();
  return service;
});
