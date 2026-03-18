import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'wallet_service.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final WalletService _walletService = WalletService();

  // ── Singleton ──
  static final ChallengeService _instance = ChallengeService._internal();
  factory ChallengeService() => _instance;
  ChallengeService._internal();

  String _slugify(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  String getEnrollmentCollectionName(String title) {
    return '${_slugify(title)}_24_competition';
  }

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

  static DateTime? _toDateTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) {
      if (v > 10000000000) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.fromMillisecondsSinceEpoch(v * 1000);
    }
    return null;
  }

  /// Stream of competitions that are "live" now: status ACTIVE, or UPCOMING with start_at <= now <= end_at (or start_at <= now if end missing).
  Stream<List<QueryDocumentSnapshot>> getLiveCompetitionsStream({
    String? sportType,
  }) {
    List<QueryDocumentSnapshot>? latestActive;
    List<QueryDocumentSnapshot>? latestUpcoming;
    final controller =
        StreamController<List<QueryDocumentSnapshot>>.broadcast();
    var emitted = false;

    void emitMerged() {
      final now = DateTime.now();
      final activeDocs = latestActive ?? [];
      final upDocs = (latestUpcoming ?? []).where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return false;
        final start = _toDateTime(data['start_at']);
        final end = _toDateTime(data['end_at']);
        if (start == null) return false;
        if (end != null) return !now.isBefore(start) && !now.isAfter(end);
        return !now.isBefore(start);
      }).toList();
      final combined = <QueryDocumentSnapshot>[...activeDocs, ...upDocs];
      combined.sort((a, b) {
        final aStart = _toDateTime(
          (a.data() as Map<String, dynamic>)['start_at'],
        );
        final bStart = _toDateTime(
          (b.data() as Map<String, dynamic>)['start_at'],
        );
        if (aStart == null) return 1;
        if (bStart == null) return -1;
        return aStart.compareTo(bStart);
      });
      emitted = true;
      if (!controller.isClosed) controller.add(combined);
    }

    void maybeEmitEmpty() {
      if (!emitted && (!controller.isClosed)) {
        controller.add(<QueryDocumentSnapshot>[]);
      }
    }

    final subActive = getCompetitionsStream('ACTIVE', sportType: sportType)
        .listen(
          (snap) {
            latestActive = snap.docs;
            emitMerged();
          },
          onError: controller.addError,
          onDone: () => maybeEmitEmpty(),
        );
    final subUpcoming = getCompetitionsStream('UPCOMING', sportType: sportType)
        .listen(
          (snap) {
            latestUpcoming = snap.docs;
            emitMerged();
          },
          onError: controller.addError,
          onDone: () => maybeEmitEmpty(),
        );

    controller.onCancel = () {
      subActive.cancel();
      subUpcoming.cancel();
    };

    return controller.stream;
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
    required String competitionTitle,
    required String userId,
    required String displayName,
    required String avatarUrl,
    required String gender,
    required int joiningFee,
  }) async {
    final enrollmentCol = getEnrollmentCollectionName(competitionTitle);

    // 1. Prevent duplicate joins
    final existing = await _firestore
        .collection(enrollmentCol)
        .doc(userId)
        .get();
    if (existing.exists) return;

    // 2. Check capacity
    final comp = await _firestore
        .collection('competitions')
        .doc(competitionId)
        .get();
    if (!comp.exists) return;

    final compData = comp.data();
    if (compData == null) return;

    final current = compData['current_participants'] ?? 0;
    final cap = compData['participant_cap'] ?? 999999;

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

    // Allocate random position/score for demo
    final randomScore =
        500 + (1000 * (1.0 - (DateTime.now().millisecond / 1000))).toInt();

    batch.set(_firestore.collection(enrollmentCol).doc(userId), {
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'joined_at': FieldValue.serverTimestamp(),
      'score': randomScore,
      'time_elapsed': '00:00',
      'final_rank': null,
      'points_earned': 0,
    });

    batch.update(_firestore.collection('competitions').doc(competitionId), {
      'current_participants': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> quitCompetition({
    required String competitionId,
    required String competitionTitle,
    required String userId,
  }) async {
    final enrollmentCol = getEnrollmentCollectionName(competitionTitle);
    final batch = _firestore.batch();
    batch.delete(_firestore.collection(enrollmentCol).doc(userId));
    batch.update(_firestore.collection('competitions').doc(competitionId), {
      'current_participants': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Stream<DocumentSnapshot> getUserEnrollmentStream(
    String title,
    String userId,
  ) {
    return _firestore
        .collection(getEnrollmentCollectionName(title))
        .doc(userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getParticipantsStream(String title) {
    return _firestore
        .collection(getEnrollmentCollectionName(title))
        .orderBy('score', descending: true)
        .limit(100)
        .snapshots();
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
        .where('status', isEqualTo: 'ACTIVE')
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

    final roomData = room.data();
    if (roomData == null) return;

    final current = roomData['current_participants'] ?? 0;
    final cap = roomData['max_participants'] ?? 999999;

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

  /// Stream of current user's join request for a room (to show Sent/Rejected/Accepted).
  Stream<DocumentSnapshot> getJoinRequestStream(String roomId, String userId) {
    return _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(userId)
        .snapshots();
  }

  /// Stream of pending join requests for a room (for owner/admin to accept/reject).
  Stream<QuerySnapshot> getJoinRequestsStream(String roomId) {
    return _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('join_requests')
        .where('status', isEqualTo: 'PENDING')
        .snapshots();
  }

  Future<void> acceptJoinRequest({
    required String roomId,
    required String requestUserId,
    required String displayName,
    required String avatarUrl,
  }) async {
    final roomRef = _firestore.collection('challenge_rooms').doc(roomId);
    final requestRef = roomRef.collection('join_requests').doc(requestUserId);

    await _firestore.runTransaction((transaction) async {
      final roomDoc = await transaction.get(roomRef);
      if (!roomDoc.exists) throw Exception('Room not found');

      transaction.update(requestRef, {
        'status': 'ACCEPTED',
        'resolved_at': FieldValue.serverTimestamp(),
      });

      final participantIds = List<String>.from(roomDoc.get('participant_ids') ?? []);
      if (participantIds.contains(requestUserId)) return;

      transaction.update(roomRef, {
        'participant_ids': FieldValue.arrayUnion([requestUserId]),
        'current_participants': FieldValue.increment(1),
      });

      final participantRef = roomRef.collection('participants').doc(requestUserId);
      transaction.set(participantRef, {
        'user_id': requestUserId,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'joined_at': FieldValue.serverTimestamp(),
        'rank': participantIds.length + 1,
        'score': 0,
      });
    });
  }

  Future<void> rejectJoinRequest({
    required String roomId,
    required String requestUserId,
  }) async {
    await _firestore
        .collection('challenge_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(requestUserId)
        .update({
          'status': 'REJECTED',
          'resolved_at': FieldValue.serverTimestamp(),
        });
  }

  /// Add a user as room admin (owner or existing admin can call).
  Future<void> addRoomAdmin({required String roomId, required String userId}) async {
    await _firestore.collection('challenge_rooms').doc(roomId).update({
      'admin_ids': FieldValue.arrayUnion([userId]),
    });
  }

  /// Remove a user from room admins (owner only).
  Future<void> removeRoomAdmin({required String roomId, required String userId}) async {
    await _firestore.collection('challenge_rooms').doc(roomId).update({
      'admin_ids': FieldValue.arrayRemove([userId]),
    });
  }

  /// Remove a member from the room (owner/admin only).
  Future<void> removeRoomMember({
    required String roomId,
    required String userId,
  }) async {
    final roomRef = _firestore.collection('challenge_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomDoc = await transaction.get(roomRef);
      if (!roomDoc.exists) return;

      final adminId = roomDoc.get('admin_id');
      if (userId == adminId) return;

      transaction.update(roomRef, {
        'participant_ids': FieldValue.arrayRemove([userId]),
        'current_participants': FieldValue.increment(-1),
      });
      transaction.delete(roomRef.collection('participants').doc(userId));
    });
  }

  // ── New Private Zone Stream Methods ──
  Stream<QuerySnapshot> getDiscoverRoomsStream() {
    return _firestore
        .collection('challenge_rooms')
        .where('status', isEqualTo: 'ACTIVE')
        .snapshots();
  }

  Stream<QuerySnapshot> getMyRoomsStream(String userId) {
    return _firestore
        .collection('challenge_rooms')
        .where('admin_id', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getJoinedRoomsStream(String userId) {
    return _firestore
        .collection('challenge_rooms')
        .where('participant_ids', arrayContains: userId)
        .snapshots();
  }

  Future<void> createChallengeRoom({
    required String adminId,
    required String adminName,
    required String adminAvatar,
    required String name,
    required String rules,
    required DateTime? startAt,
    required DateTime? endAt,
    required int entryFee,
    required int maxPlayers,
    required int prizeAmount,
    required bool isPublic,
    File? imageFile,
    double? locationLat,
    double? locationLng,
    List<Map<String, double>>? routePolyline,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(
        imageFile: imageFile,
        storagePath:
            'challenge_rooms/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final docRef = _firestore.collection('challenge_rooms').doc();
    final roomData = {
      'id': docRef.id,
      'admin_id': adminId,
      'admin_display_name': adminName,
      'admin_avatar_url': adminAvatar,
      'name': name,
      'rules': rules,
      'start_at': startAt != null ? Timestamp.fromDate(startAt) : null,
      'end_at': endAt != null ? Timestamp.fromDate(endAt) : null,
      'entry_fee': entryFee,
      'max_participants': maxPlayers,
      'visibility': isPublic ? 'Public' : 'Private',
      'prize_amount': prizeAmount,
      'image_url': imageUrl ?? 'assets/challenge/challenge_24_main_1.png',
      'status': 'ACTIVE',
      'current_participants': 1,
      'participant_ids': [adminId],
      'admin_ids': [adminId],
      'location_lat': locationLat,
      'location_lng': locationLng,
      'route_polyline': routePolyline,
      'invite_code': generateInviteCode(),
      'created_at': FieldValue.serverTimestamp(),
    };

    await docRef.set(roomData);

    // Add admin as first participant
    await docRef.collection('participants').doc(adminId).set({
      'user_id': adminId,
      'display_name': adminName,
      'avatar_url': adminAvatar,
      'joined_at': FieldValue.serverTimestamp(),
      'rank': 1,
      'score': 0,
    });
  }

  Future<void> joinChallengeRoom({
    required String roomId,
    required String userId,
    required String userName,
    required String userAvatar,
  }) async {
    final roomRef = _firestore.collection('challenge_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomDoc = await transaction.get(roomRef);
      if (!roomDoc.exists) throw Exception('Room not found');

      final participantIds = List<String>.from(
        roomDoc.get('participant_ids') ?? [],
      );
      if (participantIds.contains(userId)) return; // Already joined

      transaction.update(roomRef, {
        'participant_ids': FieldValue.arrayUnion([userId]),
        'current_participants': FieldValue.increment(1),
      });

      final participantRef = roomRef.collection('participants').doc(userId);
      transaction.set(participantRef, {
        'user_id': userId,
        'display_name': userName,
        'avatar_url': userAvatar,
        'joined_at': FieldValue.serverTimestamp(),
        'rank': participantIds.length + 1,
        'score': 0,
      });
    });
  }

  Future<void> quitChallengeRoom({
    required String roomId,
    required String userId,
  }) async {
    final roomRef = _firestore.collection('challenge_rooms').doc(roomId);
    
    await _firestore.runTransaction((transaction) async {
      final roomDoc = await transaction.get(roomRef);
      if (!roomDoc.exists) return;

      transaction.update(roomRef, {
        'participant_ids': FieldValue.arrayRemove([userId]),
        'current_participants': FieldValue.increment(-1),
      });

      final participantRef = roomRef.collection('participants').doc(userId);
      transaction.delete(participantRef);
    });
  }

  /// Stream of a single challenge room document (for joined detail screen).
  Stream<DocumentSnapshot> getRoomStream(String roomId) {
    return _firestore.collection('challenge_rooms').doc(roomId).snapshots();
  }

  // ── Leaderboard ─-
  Stream<QuerySnapshot> getRoomParticipantsStream(String roomId) {
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

  // ── Enrollment ──
  Future<bool> checkEnrollment(String userId) async {
    final doc = await _firestore
        .collection('challenge_registrations')
        .doc(userId)
        .get();
    return doc.exists && (doc.data()?['isEnrolled'] ?? false);
  }

  Future<void> enrollUser(String userId, int amount) async {
    // 1. Deduct points
    await _walletService.deduct(userId, amount, reason: 'challenge_entry');

    // 2. Set enrollment status
    await _firestore.collection('challenge_registrations').doc(userId).set({
      'userId': userId,
      'isEnrolled': true,
      'enrolledAt': FieldValue.serverTimestamp(),
    });
  }

  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
