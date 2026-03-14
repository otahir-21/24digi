import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'wallet_service.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final WalletService _walletService = WalletService();

  // ── Singleton ──
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  // ── Initialization ──
  Future<void> initializeLocks() async {
    await _firestore.collection('app_config').doc('challenge_locks').set({
      'private_zone_locked': true,
      'ai_challenge_locked': true,
      'adventure_zone_locked': true,
    }, SetOptions(merge: true));
  }

  // ── Lock Config ──
  Stream<DocumentSnapshot> getLocksStream() {
    return _firestore
        .collection('app_config')
        .doc('challenge_locks')
        .snapshots();
  }

  // ── Competitions ──
  Stream<QuerySnapshot> getCompetitionsStream(
    String status, {
    String? sportType,
  }) {
    Query query = _firestore
        .collection('competitions')
        .where('status', isEqualTo: status);

    if (sportType != null && sportType != 'All') {
      query = query.where('sport_type', isEqualTo: sportType);
    }

    if (status == 'COMPLETED') {
      query = query.orderBy('end_at', descending: true);
    } else {
      // NOTE: This requires a composite index: (status, start_at)
      query = query.orderBy('start_at', descending: false);
    }

    return query.snapshots();
  }

  Future<void> createCompetition(Map<String, dynamic> data) async {
    await _firestore.collection('competitions').add({
      ...data,
      'current_participants': 0,
      'interested_count': 0, // Initialize interested count
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // ── Notifications ──
  Future<bool> toggleNotification({
    required String competitionId,
    required String userId,
  }) async {
    final docId = '${competitionId}_$userId';
    final docRef = _firestore
        .collection('competition_notifications')
        .doc(docId);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
      // Optionally decrement interested_count if we want to track it this way
      await _firestore.collection('competitions').doc(competitionId).update({
        'interested_count': FieldValue.increment(-1),
      });
      return false; // Removed
    } else {
      await docRef.set({
        'competition_id': competitionId,
        'user_id': userId,
        'created_at': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('competitions').doc(competitionId).update({
        'interested_count': FieldValue.increment(1),
      });
      return true; // Added
    }
  }

  Stream<bool> isUserNotifiedStream(String competitionId, String userId) {
    final docId = '${competitionId}_$userId';
    return _firestore
        .collection('competition_notifications')
        .doc(docId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<DocumentSnapshot> getCompetitionStream(String competitionId) {
    return _firestore.collection('competitions').doc(competitionId).snapshots();
  }

  Future<DocumentSnapshot?> getParticipantDoc(
    String competitionId,
    String userId,
  ) async {
    final doc = await _firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .doc(userId)
        .get();
    return doc.exists ? doc : null;
  }

  Future<void> joinCompetition({
    required String competitionId,
    required String userId,
    required String displayName,
    required String avatarUrl,
    required int joiningFee,
  }) async {
    // 1. Prevent duplicate joins
    final existing = await _firestore
        .collection('competitions')
        .doc(competitionId)
        .collection('participants')
        .doc(userId)
        .get();
    if (existing.exists) return;

    // 2. Check capacity
    final comp = await _firestore
        .collection('competitions')
        .doc(competitionId)
        .get();
    if (!comp.exists) return;

    final current = comp['current_participants'] ?? 0;
    final cap = comp['participant_cap'] ?? 999999;

    if (current >= cap) {
      throw Exception('competition_full');
    }

    // 3. Deduct fee
    if (joiningFee > 0) {
      await _walletService.deduct(
        userId,
        joiningFee,
        reason: 'competition_join',
      );
    }

    // 4. Write participant + increment count atomically
    final batch = _firestore.batch();
    batch.set(
      _firestore
          .collection('competitions')
          .doc(competitionId)
          .collection('participants')
          .doc(userId),
      {
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'joined_at': FieldValue.serverTimestamp(),
        'score': 0,
        'time_elapsed': '00:00',
        'final_rank': null,
        'points_earned': 0,
      },
    );
    batch.update(_firestore.collection('competitions').doc(competitionId), {
      'current_participants': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> quitCompetition({
    required String competitionId,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    batch.delete(
      _firestore
          .collection('competitions')
          .doc(competitionId)
          .collection('participants')
          .doc(userId),
    );
    batch.update(_firestore.collection('competitions').doc(competitionId), {
      'current_participants': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  // ── Sponsor Requests ──
  Future<void> submitSponsorRequest(Map<String, dynamic> data) async {
    await _firestore.collection('sponsor_requests').add({
      ...data,
      'status': 'PENDING',
      'submitted_at': FieldValue.serverTimestamp(),
    });
  }

  // ── Challenge Rooms (Private Zone) ──
  Stream<QuerySnapshot> getOpenRoomsStream() {
    return _firestore
        .collection('challenge_rooms')
        .where('visibility', isEqualTo: 'OPEN')
        .where('status', whereIn: ['LOBBY', 'ACTIVE'])
        .orderBy('created_at', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> joinOpenRoom({
    required String roomId,
    required String userId,
    required String displayName,
    required String avatarUrl,
    required int joiningFee,
  }) async {
    final existing = await _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('participants')
        .doc(userId)
        .get();
    if (existing.exists) return;

    final room = await _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .get();
    if (!room.exists) return;

    final current = room['current_participants'] ?? 0;
    final cap = room['max_participants'] ?? 999999;

    if (current >= cap) {
      throw Exception('room_full');
    }

    if (joiningFee > 0) {
      await _walletService.deduct(userId, joiningFee, reason: 'room_join');
    }

    final batch = _firestore.batch();
    batch.set(
      _firestore
          .collection('challenge_rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId),
      {
        'user_id': userId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'joined_at': FieldValue.serverTimestamp(),
        'rank': 0,
        'calories': 0,
        'duration': '0h 0m',
        'heart_rate': 0,
        'distance': 0.0,
        'pace': "0'00\"",
        'points_earned': 0,
        'final_rank': null,
      },
    );
    batch.update(_firestore.collection('challenge_rooms').doc(roomId), {
      'current_participants': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> requestJoinLockedRoom({
    required String roomId,
    required String userId,
    required String displayName,
    required String avatarUrl,
  }) async {
    final existing = await _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(userId)
        .get();
    if (existing.exists) return;

    await _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(userId)
        .set({
          'user_id': userId,
          'display_name': displayName,
          'avatar_url': avatarUrl,
          'status': 'PENDING',
          'requested_at': FieldValue.serverTimestamp(),
          'resolved_at': null,
          'fee_charged': false,
        });
  }

  Future<void> createRoom(Map<String, dynamic> data, String creatorId) async {
    final docRef = await _firestore.collection('challenge_rooms').add({
      ...data,
      'current_participants': 1,
      'started_at': null,
      'ended_at': null,
      'created_at': FieldValue.serverTimestamp(),
    });

    // Add creator as first participant
    await docRef.collection('participants').doc(creatorId).set({
      'user_id': creatorId,
      'display_name': data['admin_display_name'],
      'avatar_url': data['admin_avatar_url'],
      'joined_at': FieldValue.serverTimestamp(),
      'rank': 1,
      'calories': 0,
      'duration': '0h 0m',
      'heart_rate': 0,
      'distance': 0.0,
      'pace': "0'00\"",
      'points_earned': 0,
      'final_rank': null,
    });
  }

  // ── Leaderboard ──
  Stream<QuerySnapshot> getParticipantsStream(String roomId) {
    return _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('participants')
        .orderBy('rank', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getGlobalLeaderboardStream({String? sportType}) {
    Query query = _firestore.collection('global_leaderboard');
    if (sportType != null && sportType != 'All') {
      query = query.where('sport_type', isEqualTo: sportType);
    }
    return query
        .orderBy('total_points', descending: true)
        .limit(10)
        .snapshots();
  }

  // ── Chat ──
  Stream<QuerySnapshot> getMessagesStream(String roomId) {
    return _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('sent_at', descending: false)
        .limit(50)
        .snapshots();
  }

  Future<void> sendMessage(
    String roomId,
    Map<String, dynamic> messageData,
  ) async {
    await _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('messages')
        .add({...messageData, 'sent_at': FieldValue.serverTimestamp()});
  }

  // ── Image Handling ──
  Future<String> uploadImage({
    required File imageFile,
    required String storagePath,
  }) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 800,
      minHeight: 600,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) throw Exception('Compression failed');

    final ref = _storage.ref(storagePath);
    await ref.putData(compressed, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
