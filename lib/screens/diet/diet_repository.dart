import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/diet_models.dart';

class DietRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DietCategory>> getCategories() async {
    final snapshot = await _firestore.collection('24diet_productcategories').get();
    return snapshot.docs
        .map((doc) => DietCategory.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<DietProduct>> getProducts() async {
    final snapshot = await _firestore.collection('24diet_products').get();
    return snapshot.docs
        .map((doc) => DietProduct.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<DietProduct>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    // Firestore 'whereIn' is limited to 10-30 items depending on version, but 
    // since we might have many, we'll fetch them all and filter or batch if necessary.
    // For now, let's fetch products and filter in memory if the list is small, 
    // or use whereIn if it's less than 30.
    final snapshot = await _firestore
        .collection('24diet_products')
        .where(FieldPath.documentId, whereIn: ids.take(30).toList())
        .get();
    return snapshot.docs
        .map((doc) => DietProduct.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<DietProduct>> getRandomProducts({int limit = 5}) async {
    final snapshot = await _firestore.collection('24diet_products').limit(20).get();
    final products = snapshot.docs
        .map((doc) => DietProduct.fromFirestore(doc.data(), doc.id))
        .toList();
    products.shuffle();
    return products.take(limit).toList();
  }

  Future<List<DietProduct>> getProductsByCategory(String categoryId) async {
    // Try both productCategory field and potential products list lookup
    final snapshot = await _firestore
        .collection('24diet_products')
        .where('productCategory', isEqualTo: categoryId)
        .get();
    
    return snapshot.docs
        .map((doc) => DietProduct.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // ADDRESSES
  Future<void> saveAddress(DietAddress address) async {
    if (address.id.isEmpty) {
      await _firestore.collection('24diet_addresses').add(address.toMap());
    } else {
      await _firestore.collection('24diet_addresses').doc(address.id).update(address.toMap());
    }
  }

  Future<List<DietAddress>> getAddresses(String userId) async {
    final snapshot = await _firestore
        .collection('24diet_addresses')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => DietAddress.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<void> deleteAddress(String addressId) async {
    await _firestore.collection('24diet_addresses').doc(addressId).delete();
  }

  // ORDERS
  Future<void> createOrder(DietOrder order) async {
    await _firestore.collection('24diet_orders').add(order.toMap());
  }
}
