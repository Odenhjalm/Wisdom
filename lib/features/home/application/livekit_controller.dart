import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import 'package:wisdom/data/repositories/sfu_repository.dart';

class LiveSessionState {
  const LiveSessionState({
    this.connecting = false,
    this.connected = false,
    this.error,
    this.room,
    this.wsUrl,
    this.token,
  });

  final bool connecting;
  final bool connected;
  final String? error;
  final Room? room;
  final String? wsUrl;
  final String? token;

  LiveSessionState copyWith({
    bool? connecting,
    bool? connected,
    String? error,
    Room? room,
    String? wsUrl,
    String? token,
  }) {
    return LiveSessionState(
      connecting: connecting ?? this.connecting,
      connected: connected ?? this.connected,
      error: error,
      room: room ?? this.room,
      wsUrl: wsUrl ?? this.wsUrl,
      token: token ?? this.token,
    );
  }
}

class LiveSessionController extends AutoDisposeNotifier<LiveSessionState> {
  late final SfuRepository _repository;

  @override
  LiveSessionState build() {
    _repository = ref.watch(sfuRepositoryProvider);
    ref.onDispose(_cleanupRoom);
    return const LiveSessionState();
  }

  Future<void> connect(String seminarId) async {
    if (state.connecting || state.connected) return;
    state = state.copyWith(connecting: true, error: null);

    try {
      final tokenResponse = await _repository.fetchToken(seminarId);
      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );

      await room.connect(
        tokenResponse.wsUrl,
        tokenResponse.token,
      );

      room.addListener(_onRoomChanged);

      state = state.copyWith(
        connecting: false,
        connected: true,
        room: room,
        wsUrl: tokenResponse.wsUrl,
        token: tokenResponse.token,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        connecting: false,
        connected: false,
        error: error.toString(),
      );
      await _cleanupRoom();
    }
  }

  Future<void> disconnect() async {
    if (!state.connected && !state.connecting) return;
    await _cleanupRoom();
    state = const LiveSessionState();
  }

  Future<void> _cleanupRoom() async {
    final room = state.room;
    if (room != null) {
      room.removeListener(_onRoomChanged);
      try {
        await room.disconnect();
      } catch (_) {
        // swallow disconnect errors in teardown
      }
      await room.dispose();
    }
  }

  void _onRoomChanged() {
    final room = state.room;
    if (room == null) return;
    state = state.copyWith(
        connected: room.connectionState == ConnectionState.connected);
  }
}

final liveSessionControllerProvider =
    AutoDisposeNotifierProvider<LiveSessionController, LiveSessionState>(
  LiveSessionController.new,
);
