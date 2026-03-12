import 'package:flutter/material.dart';
import '../models/diet_models.dart';

class CartItem {
  final DietProduct product;
  int quantity;
  String selectedSize;
  int selectedGrams;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = 'Medium',
    this.selectedGrams = 200,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  void addToCart(DietProduct product, int quantity,
      {String size = 'Medium', int grams = 200}) {
    final index = _items.indexWhere((item) =>
        item.product.id == product.id && item.selectedSize == size);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedGrams: grams,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId, String size) {
    _items.removeWhere(
        (item) => item.product.id == productId && item.selectedSize == size);
    notifyListeners();
  }

  void updateQuantity(String productId, String size, int quantity) {
    final index = _items.indexWhere(
        (item) => item.product.id == productId && item.selectedSize == size);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void updateItem(int index,
      {int? quantity, String? size, int? grams}) {
    if (index >= 0 && index < _items.length) {
      if (quantity != null) _items[index].quantity = quantity;
      if (size != null) _items[index].selectedSize = size;
      if (grams != null) _items[index].selectedGrams = grams;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
