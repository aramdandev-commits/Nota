import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:http/http.dart' as http;

class PusherService {
  // Singleton pattern
  PusherService._internal();
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;

  PusherChannelsClient? _client;
  Channel? _channel;
  bool _isInitialized = false;

  // AI summary callbacks
  Function(Map<String, dynamic>)? onNoteSummarized;
  Function(Map<String, dynamic>)? onNoteSummarizationFailed;

  // PDF extraction callbacks
  Function(Map<String, dynamic>)? onPdfExtracted;
  Function(Map<String, dynamic>)? onPdfExtractionFailed;

  // ── Tag for all logs ──────────────────────────────────────────────────────
  static const _tag = '🔌 PusherService';

  /// Initialize Pusher and subscribe to the user's private channel.
  Future<void> initPusher({
    required String userId,
    required String userToken,
    required String websocketHost,
    required String authUrl,
  }) async {
    if (_isInitialized) {
      debugPrint(
          '$_tag: Already initialized — skipping. isInitialized=$_isInitialized');
      return;
    }

    debugPrint('$_tag: ── Starting initialization ──────────────────');
    debugPrint('$_tag: userId      = $userId');
    debugPrint('$_tag: wsHost      = $websocketHost');
    debugPrint('$_tag: authUrl     = $authUrl');
    debugPrint(
        '$_tag: tokenPrefix = ${userToken.substring(0, userToken.length.clamp(0, 10))}...');

    try {
      const key = 'yekwtfyjtaonoyvts30o';
      final wsUri =
          'wss://$websocketHost:443/app/$key?client=dart&version=1.2.2&protocol=7';
      debugPrint('$_tag: WS URI = $wsUri');

      final options = PusherChannelsOptions.custom(
        uriResolver: (_) => Uri.parse(wsUri),
      );

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) {
          debugPrint('$_tag: ❌ Connection error: $exception');
          debugPrint('$_tag: ↩️  Retrying…');
          refresh();
        },
      );

      // Listen to raw connection state changes globally
      _client!.eventStream.listen((event) {
        debugPrint(
            '🌐 [RAW] Channel: ${event.channelName}, Event: ${event.name}, Data: ${event.data}');
      });

      // Public channel — no auth required
      final channelName = 'users.$userId';
      debugPrint('$_tag: Subscribing to public channel: $channelName');

      _channel = _client!.publicChannel(channelName);

      // Bind all lifecycle and custom events
      _bindEvents();

      // Connect first, then subscribe + probe AFTER connection is established
      _client!.connect();

      _client!.onConnectionEstablished.listen((_) {
        debugPrint(
            '$_tag: ✅ WebSocket TCP connected — subscribing to channel now');
        _channel!.subscribe();
      });

      _isInitialized = true;
      debugPrint('$_tag: ✅ Initialized — waiting for connection to establish…');
    } catch (e, st) {
      debugPrint('$_tag: ❌ Initialization threw: $e');
      debugPrint('$_tag: $st');
    }
  }

  void _bindEvents() {
    if (_channel == null) return;

    // ── Connection / Subscription Lifecycle (Equivalent to JS .error()) ──
    _channel!.bind('pusher_internal:subscription_succeeded').listen((event) {
      debugPrint('$_tag: ✅ Subscription SUCCEEDED → ${_channel!.name}');
      debugPrint('$_tag: All events are now live. Waiting for server events…');
    });

    _channel!.bind('pusher_internal:subscription_error').listen((event) {
      debugPrint(
          '$_tag: ❌ Subscription FAILED (Internal) → data: ${event.data}');
    });

    _channel!.bind('pusher:subscription_error').listen((event) {
      debugPrint(
          '$_tag: ❌ WEBSOCKET AUTH ERROR (JS .error() equivalent) → data: ${event.data}');
    });

    _channel!.bind('pusher:error').listen((event) {
      debugPrint('$_tag: ❌ GENERAL WEBSOCKET ERROR → data: ${event.data}');
    });

    // ── AI Summarization "Fishing Net" Multi-bindings ───────────────────
    final noteSuccessEvents = [
      'note.summarized',
      '.note.summarized',
      'App\\Events\\NoteSummarized'
    ];
    for (final eventName in noteSuccessEvents) {
      _channel!.bind(eventName).listen((event) {
        debugPrint('$_tag: 🎯 CAUGHT NOTE SUMMARIZED EVENT [$eventName]');
        debugPrint('$_tag:    raw data = ${event.data}');
        final data = _parse(event.data);
        debugPrint('$_tag:    parsed   = $data');
        onNoteSummarized?.call(data);
      });
    }

    final noteFailedEvents = [
      'note.summarization_failed',
      '.note.summarization_failed',
      'App\\Events\\NoteSummarizationFailed'
    ];
    for (final eventName in noteFailedEvents) {
      _channel!.bind(eventName).listen((event) {
        debugPrint('$_tag: 📩 note.summarization_failed received [$eventName]');
        debugPrint('$_tag:    raw data = ${event.data}');
        final data = _parse(event.data);
        onNoteSummarizationFailed?.call(data);
      });
    }

    // ── PDF Extraction "Fishing Net" Multi-bindings ──────────────────────
    final pdfSuccessEvents = [
      'pdf.extracted',
      '.pdf.extracted',
      'App\\Events\\PdfExtracted'
    ];
    for (final eventName in pdfSuccessEvents) {
      _channel!.bind(eventName).listen((event) {
        debugPrint('$_tag: 🎯 CAUGHT PDF SUCCESS EVENT [$eventName]');
        debugPrint('$_tag:    raw data = ${event.data}');
        final data = _parse(event.data);
        debugPrint('$_tag:    parsed   = $data');
        if (onPdfExtracted == null) {
          debugPrint(
              '$_tag: ⚠️  onPdfExtracted callback is NULL — NoteProvider not wired yet?');
        }
        onPdfExtracted?.call(data);
      });
    }

    final pdfFailedEvents = [
      'pdf.extraction_failed',
      '.pdf.extraction_failed',
      'App\\Events\\PdfExtractionFailed'
    ];
    for (final eventName in pdfFailedEvents) {
      _channel!.bind(eventName).listen((event) {
        debugPrint('$_tag: ❌ CAUGHT PDF FAILED EVENT [$eventName]');
        debugPrint('$_tag:    raw data = ${event.data}');
        final data = _parse(event.data);
        onPdfExtractionFailed?.call(data);
      });
    }
  }

  // ── Central Safe JSON Parser ──────────────────────────────────────────────
  Map<String, dynamic> _parse(dynamic raw) {
    if (raw == null) return {};
    try {
      if (raw is Map) return Map<String, dynamic>.from(raw);
      return jsonDecode(raw.toString()) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('$_tag: ⚠️  Could not parse event data: $e');
      return {};
    }
  }

  // ── Auth endpoint probe ───────────────────────────────────────────────────
  Future<void> _probeAuthEndpoint({
    required String authUrl,
    required String token,
    required String channelName,
  }) async {
    debugPrint('$_tag: 🔍 Probing auth endpoint…');
    debugPrint('$_tag:    URL     = $authUrl');
    debugPrint('$_tag:    channel = $channelName');
    try {
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'channel_name': channelName,
          'socket_id': '000000.00000000',
        }),
      );
      debugPrint('$_tag: 🔍 Auth probe → HTTP ${response.statusCode}');
      debugPrint('$_tag: 🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('$_tag: ✅ Auth endpoint OK');
      } else if (response.statusCode == 403) {
        debugPrint(
            '$_tag: ❌ 403 — token rejected or channel not authorized in routes/channels.php');
      } else if (response.statusCode == 401) {
        debugPrint(
            '$_tag: ❌ 401 — Bearer token invalid or Sanctum guard not applied');
      } else if (response.statusCode == 404) {
        debugPrint(
            '$_tag: ❌ 404 — route not found. Try /api/broadcasting/auth');
      } else if (response.statusCode == 302 || response.statusCode == 301) {
        debugPrint('$_tag: ❌ Redirect — auth route behind web middleware');
      } else if (response.body.contains('<html')) {
        debugPrint(
            '$_tag: ❌ Auth returned HTML — Laravel error page or ngrok warning page');
      }
    } catch (e) {
      debugPrint('$_tag: ❌ Auth probe threw: $e');
    }
  }

  /// Disconnects from Pusher. Call this on logout.
  void disconnect() {
    if (!_isInitialized) return;
    try {
      _channel?.unsubscribe();
      _client?.disconnect();
      _client?.dispose();
      _isInitialized = false;
      _client = null;
      _channel = null;
      debugPrint('$_tag: 🔴 Disconnected successfully');
    } catch (e) {
      debugPrint('$_tag: ❌ Disconnect error: $e');
    }
  }
}
