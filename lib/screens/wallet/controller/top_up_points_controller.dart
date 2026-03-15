import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TopUpPointsController extends GetxController{
  final RxString selectedMethodId = "1".obs;

  final RxList<PaymentMethodModel> paymentMethods = [
    PaymentMethodModel(
      id: "1",
      title: "Visa",
      description: "•••• 4892 • Exp 09/27",
      prefixIcon: "assets/icons/Wallet.png",
      iconColor: const Color(0xff1A1F71),
    ),
    PaymentMethodModel(
      id: "2",
      title: "Mastercard",
      description: "•••• 1234 • Exp 12/28",
      prefixIcon: "assets/icons/Wallet.png",
      iconColor: const Color(0xffEB001B),
    ),
    PaymentMethodModel(
      id: "3",
      title: "Apple Pay",
      prefixIcon: "assets/icons/Wallet.png", // Description is optional
      iconColor: Colors.white,
    ),
    PaymentMethodModel(
      id: "4",
      title: "Google Pay",
      prefixIcon: "assets/icons/Wallet.png", // Description is optional
      iconColor: Color(0xff4285F4),
    ),
  ].obs;

  void selectMethod(String id) {
    selectedMethodId.value = id;
  }
}

class PaymentMethodModel {
  final String id; // Unique ID to track selection
  final String title;
  final String? description; // Optional as requested
  final String prefixIcon;
  final Color iconColor;

  PaymentMethodModel({
    required this.id,
    required this.title,
    this.description,
    required this.prefixIcon,
    required this.iconColor,
  });
}