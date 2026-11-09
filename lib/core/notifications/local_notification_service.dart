import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:produtividade_tcc/core/notifications/web_notification_helper.dart';

/// Serviço gerenciador de Notificações Locais (`RF21`, `ADR-008`).
///
/// Encapsula [FlutterLocalNotificationsPlugin] no Android/iOS e a [Web Notifications API]
/// no navegador, garantindo notificações reais e seguras em todas as plataformas.
class LocalNotificationService {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Registrador de testes para inspecionar notificações disparadas sem depender de canal de plataforma.
  final List<Map<String, dynamic>> testNotificationLog = <Map<String, dynamic>>[];

  /// Mapa de timers periódicos ativos por id (para Web e foreground em mobile).
  final Map<int, Timer> _activePeriodicTimers = <int, Timer>{};

  bool get isInitialized => _initialized;

  /// Inicializa o plugin suavemente.
  Future<bool> initialize() async {
    if (_initialized) return true;

    // Em ambiente Web: solicita permissão via Web Notifications API
    if (kIsWeb) {
      _initialized = true;
      try {
        await requestWebNotificationPermission();
      } catch (e) {
        debugPrint('[LocalNotificationService] Web permission request: $e');
      }
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
  Future<bool> showTestNotification({
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

    // Se estiver no navegador Web: dispara notificação real via Web Notifications API
    if (kIsWeb) {
      final bool sent = await showWebNotification(title, body);
      debugPrint('[LocalNotificationService - Web] Notificação nativa disparada: $sent');
      return sent;
    }

    if (!_initialized) {
      debugPrint('[LocalNotificationService - Test] Alerta registrado no log: $title - $body');
      return true;
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
      return true;
    } catch (e, stack) {
      debugPrint('[LocalNotificationService] Erro ao exibir notificação de teste: $e\n$stack');
      return false;
    }
  }

  /// Agenda um lembrete periódico com intervalo em minutos (Web e Mobile).
  Future<void> schedulePeriodic({
    required int id,
    required String title,
    required String body,
    required int intervalMinutes,
  }) async {
    // Cancela timer ou notificação anterior com este ID
    await cancel(id);

    final Duration duration = Duration(minutes: intervalMinutes);

    // Inicia Timer periódico ativo no app para Web e foreground mobile
    _activePeriodicTimers[id] = Timer.periodic(duration, (_) {
      showTestNotification(id: id, title: title, body: body);
    });

    // Se estiver no mobile com plugin nativo inicializado, agenda repetição se suportado
    if (!kIsWeb && _initialized) {
      try {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'lembretes_cognitivos',
          'Lembretes de Saúde Cognitiva',
          channelDescription:
              'Alertas periódicos de hidratação, pausa ativa, sono e fechamento reflexivo',
          importance: Importance.high,
          priority: Priority.high,
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

        // Agendamento periódico nativo (ex: RepeatInterval.hourly se >= 60)
        final RepeatInterval repeatInterval = intervalMinutes >= 60
            ? RepeatInterval.hourly
            : RepeatInterval.everyMinute;

        await _plugin.periodicallyShow(
          id: id,
          title: title,
          body: body,
          repeatInterval: repeatInterval,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('[LocalNotificationService] Fallback nativo: $e');
      }
    }
  }

  /// Cancela um lembrete específico por ID.
  Future<void> cancel(int id) async {
    _activePeriodicTimers[id]?.cancel();
    _activePeriodicTimers.remove(id);

    if (kIsWeb || !_initialized) return;
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('[LocalNotificationService] Erro ao cancelar notificação $id: $e');
    }
  }

  /// Cancela todos os lembretes agendados.
  Future<void> cancelAll() async {
    for (final Timer timer in _activePeriodicTimers.values) {
      timer.cancel();
    }
    _activePeriodicTimers.clear();

    if (kIsWeb || !_initialized) return;
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
