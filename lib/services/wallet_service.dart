import 'package:cloud_firestore/cloud_firestore.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  Future<void> deduct(String userId, int amount, {required String reason}) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) throw Exception('User not found');
      
      final currentPoints = snapshot.data()?['points'] ?? 0;
      if (currentPoints < amount) throw Exception('Insufficient points');
      
      transaction.update(userRef, {'points': currentPoints - amount});
      
      // Optionally log transaction
      final logRef = userRef.collection('wallet_transactions').doc();
      transaction.set(logRef, {
        'amount': -amount,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<DocumentSnapshot> getBalanceStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }
}
