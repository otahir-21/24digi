import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'wallet_service.dart';

class AdventureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final WalletService _walletService = WalletService();

  static final AdventureService _instance = AdventureService._internal();
  factory AdventureService() => _instance;
  AdventureService._internal();

  Stream<QuerySnapshot> getDiscoverRoomsStream() {
    return _firestore
        .collection('adventure_rooms')
        .where('status', isEqualTo: 'ACTIVE')
        .snapshots();
  }

  Stream<QuerySnapshot> getMyRoomsStream(String userId) {
    return _firestore
        .collection('adventure_rooms')
        .where('admin_id', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getJoinedRoomsStream(String userId) {
    return _firestore
        .collection('adventure_rooms')
        .where('participant_ids', arrayContains: userId)
        .snapshots();
  }

  Future<void> createAdventureRoom({
    required String adminId,
    required String adminName,
    required String adminAvatar,
    required String name,
    required String rules,
    required DateTime? startAt,
    required DateTime? endAt,
    required int entryFee,
    required int maxPlayers,
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
        storagePath: 'adventure_rooms/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final docRef = _firestore.collection('adventure_rooms').doc();
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

    await docRef.collection('participants').doc(adminId).set({
      'user_id': adminId,
      'display_name': adminName,
      'avatar_url': adminAvatar,
      'joined_at': FieldValue.serverTimestamp(),
      'rank': 1,
      'score': 0,
    });
  }

  Future<void> joinAdventureRoom({
    required String roomId,
    required String userId,
    required String userName,
    required String userAvatar,
    required int entryFee,
  }) async {
    final roomRef = _firestore.collection('adventure_rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final roomDoc = await transaction.get(roomRef);
      if (!roomDoc.exists) throw Exception('Room not found');

      final participantIds = List<String>.from(roomDoc.get('participant_ids') ?? []);
      if (participantIds.contains(userId)) return;

      final current = roomDoc.get('current_participants') ?? 0;
      final cap = roomDoc.get('max_participants') ?? 999999;
      if (current >= cap) throw Exception('room_full');

      if (entryFee > 0) {
        await _walletService.deduct(userId, entryFee, reason: 'adventure_join');
      }

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

  Future<void> quitAdventureRoom({
    required String roomId,
    required String userId,
  }) async {
    final roomRef = _firestore.collection('adventure_rooms').doc(roomId);
    
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

  Stream<DocumentSnapshot> getRoomStream(String roomId) {
    return _firestore.collection('adventure_rooms').doc(roomId).snapshots();
  }

  Future<void> requestJoinLockedRoom({
    required String roomId,
    required String userId,
    required String displayName,
    required String avatarUrl,
  }) async {
    final existing = await _firestore
        .collection('adventure_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(userId)
        .get();
    if (existing.exists) return;

    await _firestore
        .collection('adventure_rooms')
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

  Stream<DocumentSnapshot> getJoinRequestStream(String roomId, String userId) {
    return _firestore
        .collection('adventure_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getJoinRequestsStream(String roomId) {
    return _firestore
        .collection('adventure_rooms')
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
    final roomRef = _firestore.collection('adventure_rooms').doc(roomId);
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
        .collection('adventure_rooms')
        .doc(roomId)
        .collection('join_requests')
        .doc(requestUserId)
        .update({
      'status': 'REJECTED',
      'resolved_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addRoomAdmin({required String roomId, required String userId}) async {
    await _firestore.collection('adventure_rooms').doc(roomId).update({
      'admin_ids': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeRoomAdmin({required String roomId, required String userId}) async {
    await _firestore.collection('adventure_rooms').doc(roomId).update({
      'admin_ids': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> removeRoomMember({
    required String roomId,
    required String userId,
  }) async {
    final roomRef = _firestore.collection('adventure_rooms').doc(roomId);

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

  Stream<QuerySnapshot> getRoomParticipantsStream(String roomId) {
    return _firestore
        .collection('adventure_rooms')
        .doc(roomId)
        .collection('participants')
        .orderBy('rank', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessagesStream(String roomId) {
    return _firestore
        .collection('adventure_rooms')
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
        .collection('adventure_rooms')
        .doc(roomId)
        .collection('messages')
        .add({...messageData, 'sent_at': FieldValue.serverTimestamp()});
  }

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
