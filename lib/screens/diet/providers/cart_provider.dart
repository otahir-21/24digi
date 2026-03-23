import 'package:flutter/material.dart';
import '../models/diet_models.dart';

class CartItem {
  final DietProduct product;
  int quantity;
  String selectedSize;
  int selectedGrams;
  int proteinGrams;
  int carbsGrams;

  double get finalPrice => product.price + (proteinGrams > 100 ? (proteinGrams - 100) * 0.1 : 0) + (carbsGrams > 100 ? (carbsGrams - 100) * 0.05 : 0);
  double get finalCalories => product.calories + (proteinGrams > 100 ? (proteinGrams - 100) * 1.5 : 0) + (carbsGrams > 100 ? (carbsGrams - 100) * 1.2 : 0);
  double get finalProtein => product.protein + (proteinGrams > 100 ? (proteinGrams - 100) * 0.3 : 0);
  double get finalCarbs => product.carbs + (carbsGrams > 100 ? (carbsGrams - 100) * 0.3 : 0);
  double get finalFat => product.fat;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selectedSize = 'Medium',
    this.selectedGrams = 200,
    this.proteinGrams = 100,
    this.carbsGrams = 100,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + (item.finalPrice * item.quantity));

  void addToCart(DietProduct product, int quantity,
      {String size = 'Medium', int grams = 200, int proteinGrams = 100, int carbsGrams = 100}) {
    final index = _items.indexWhere((item) =>
        item.product.id == product.id && item.selectedSize == size && item.selectedGrams == grams && item.proteinGrams == proteinGrams && item.carbsGrams == carbsGrams);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size,
        selectedGrams: grams,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
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
