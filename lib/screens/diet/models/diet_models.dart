class DietCategory {
  final String id;
  final bool active;
  final String image;
  final String name;
  final String productCategoryId;
  final List<String> products;

  DietCategory({
    required this.id,
    required this.active,
    required this.image,
    required this.name,
    required this.productCategoryId,
    required this.products,
  });

  factory DietCategory.fromFirestore(Map<String, dynamic> data, String id) {
    return DietCategory(
      id: id,
      active: data['active'] ?? false,
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      productCategoryId: data['productCategoryId'] ?? '',
      products: List<String>.from(data['products'] ?? []),
    );
  }
}

class DietProduct {
  final String id;
  final bool active;
  final String description;
  final String descriptionAr;
  final String descriptionEn;
  final String foodCategory;
  final bool hasAddOns;
  final bool hasCustomizableComponents;
  final String image;
  final String name;
  final String nameAr;
  final String nameEn;
  final double price;
  final String productCategory;
  final String productId;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  DietProduct({
    required this.id,
    required this.active,
    required this.description,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.foodCategory,
    required this.hasAddOns,
    required this.hasCustomizableComponents,
    required this.image,
    required this.name,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.productCategory,
    required this.productId,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory DietProduct.fromFirestore(Map<String, dynamic> data, String id) {
    return DietProduct(
      id: id,
      active: data['active'] ?? false,
      description: data['description'] ?? '',
      descriptionAr: data['description_ar'] ?? '',
      descriptionEn: data['description_en'] ?? '',
      foodCategory: data['foodCategory'] ?? '',
      hasAddOns: data['hasAddOns'] ?? false,
      hasCustomizableComponents: data['hasCustomizableComponents'] ?? false,
      image: data['image'] ?? '',
      name: data['name'] ?? '',
      nameAr: data['name_ar'] ?? '',
      nameEn: data['name_en'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      productCategory: data['productCategory'] ?? '',
      productId: data['productId']?.toString() ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      protein: (data['protein'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fat: (data['fat'] ?? 0).toDouble(),
    );
  }
}

class DietAddress {
  final String id;
  final String userId;
  final String label;
  final String address;
  final bool isDefault;

  DietAddress({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'label': label,
      'address': address,
      'isDefault': isDefault,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory DietAddress.fromFirestore(Map<String, dynamic> data, String id) {
    return DietAddress(
      id: id,
      userId: data['userId'] ?? '',
      label: data['label'] ?? '',
      address: data['address'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }
}

class DietOrder {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String status; // pending, complete, cancelled
  final String address;
  final String paymentMethod;
  final DateTime createdAt;

  DietOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'address': address,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
