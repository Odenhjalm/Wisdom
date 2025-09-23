import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationsService {
  static final NotificationsService instance = NotificationsService._();
  NotificationsService._();

  FirebaseMessaging? get _fm {
    try {
      return FirebaseMessaging.instance;
    } catch (_) {
      return null;
    }
  }

  /// Requests permissions (iOS), returns FCM token if available.
  Future<String?> initAndGetToken() async {
    final fm = _fm;
    if (fm == null) return null;
    if (!kIsWeb) {
      await fm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
    // Foreground message handler (no-op by default; let app set listener)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // You can surface in-app banners/snackbars from caller
    });
    return fm.getToken();
  }

  /// Subscribe to notifications for a specific user; returns a cancel function.
  Future<VoidCallback?> watchMyNotifications(
      {required void Function(Map<String, dynamic> row) onInsert}) async {
    if (_fm == null) return null;
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return null;
      final chan = client
          .channel('notif-$uid')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'app',
            table: 'notifications',
            callback: (payload) {
              final row = (payload.newRecord as Map?)?.cast<String, dynamic>();
              if (row == null) return;
              // Manual filter by user_id to match current user
              if (row['user_id'] != uid) return;
              onInsert(row);
            },
          )
          .subscribe();
      return () async {
        await client.removeChannel(chan);
      };
    } catch (_) {
      return null;
    }
  }
}
