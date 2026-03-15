import 'package:get/get.dart';

class TopUpPointOneController extends GetxController{
  final RxList<PackageModel> packages = <PackageModel>[
    PackageModel(amount: "500", title: "points", price: "50 AED"),
    PackageModel(amount: "500", title: "points", price: "50 AED"),
    PackageModel(amount: "1,200", title: "points", price: "100 AED", isBestValue: true),
    PackageModel(amount: "2,500", title: "points", price: "200 AED"),
    PackageModel(amount: "2,500", title: "points", price: "200 AED"),
    PackageModel(amount: "5,000", title: "points", price: "350 AED"),
  ].obs;
}

class PackageModel {
  final String amount;
  final String title;
  final String price;
  final bool isBestValue;

  PackageModel({
    required this.amount,
    required this.title,
    required this.price,
    this.isBestValue = false,
  });
}