import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class PusherService {
  // Singleton pattern
  PusherService._internal();
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;

  PusherChannelsClient? _client;
  PrivateChannel? _channel;
  bool _isInitialized = false;

  // AI summary callbacks
  Function(Map<String, dynamic>)? onNoteSummarized;
  Function(Map<String, dynamic>)? onNoteSummarizationFailed;

  /// Initialize Pusher and subscribe to the user's private channel.
  Future<void> initPusher({
    required String userId,
    required String userToken,
    required String websocketHost,
    required String authUrl,
  }) async {
    if (_isInitialized) return;

    try {
      const key = "yekwtfyjtaonoyvts30o";

      final options = PusherChannelsOptions.custom(
        uriResolver: (options) {
          return Uri.parse(
              'wss://$websocketHost:443/app/$key?client=dart&version=1.2.2&protocol=7');
        },
      );

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) {
          debugPrint('PusherService: Connection Error: $exception');
          refresh(); // retry connection
        },
      );

      // Setup private channel
      final channelName = 'private-App.Models.User.$userId';
      final authUri = Uri.parse(authUrl);

      _channel = _client!.privateChannel(
        channelName,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate
                .forPrivateChannel(
          authorizationEndpoint: authUri,
          headers: {
            'Authorization': 'Bearer $userToken',
            'Accept': 'application/json',
          },
        ),
      );

      // Bind events
      _bindEvents();

      // Start connection
      _client!.connect();
      _channel!.subscribe();

      _isInitialized = true;
      debugPrint("PusherService: Initialized and subscribed to $channelName");
    } catch (e) {
      debugPrint("PusherService: Initialization error: $e");
    }
  }

  void _bindEvents() {
    if (_channel == null) return;

    // حدث نجاح الاشتراك باستخدام الـ String المباشر
    _channel!.bind('pusher_internal:subscription_succeeded').listen((event) {
      debugPrint('PusherService: Subscription Succeeded to ${_channel!.name}');
    });

    _channel!.bind('note.summarization_failed').listen((event) {
      debugPrint(
          "PusherService: Received note.summarization_failed: ${event.data}");
      Map<String, dynamic> data = {};
      if (event.data != null) {
        try {
          data = event.data is String
              ? jsonDecode(event.data.toString())
              : Map<String, dynamic>.from(event.data);
        } catch (_) {}
      }
      onNoteSummarizationFailed?.call(data);
    });

    _channel!.bind('note.summarized').listen((event) {
      debugPrint("PusherService: Received note.summarized: ${event.data}");
      Map<String, dynamic> data = {};
      if (event.data != null) {
        try {
          data = event.data is String
              ? jsonDecode(event.data.toString())
              : Map<String, dynamic>.from(event.data);
        } catch (_) {}
      }
      onNoteSummarized?.call(data);
    });

    _channel!.bind('pdf.extracted').listen((event) {
      debugPrint("PusherService: Received pdf.extracted: ${event.data}");
      // TODO: Call Provider
    });

    _channel!.bind('pdf.extraction_failed').listen((event) {
      debugPrint(
          "PusherService: Received pdf.extraction_failed: ${event.data}");
      // TODO: Call Provider
    });
  }

  /// Disconnects from Pusher. Call this when the user logs out.
  void disconnect() {
    if (!_isInitialized) return;
    try {
      _channel?.unsubscribe();
      _client?.disconnect();
      _client?.dispose();

      _isInitialized = false;
      _client = null;
      _channel = null;
      debugPrint("PusherService: Disconnected");
    } catch (e) {
      debugPrint("PusherService: Disconnect error: $e");
    }
  }
}
