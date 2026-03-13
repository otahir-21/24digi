import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataProtectedWidget extends StatelessWidget {
  final String? iconPath;
  final String? title;
  final String? description;
  final String? price;
  final String? unit;
  final String? message;
  final List<Color>? iconGradientColorList;
  final VoidCallback? onTrialTap;

  const DataProtectedWidget({
    super.key,
    this.iconPath,
    this.title,
    this.description,
    this.price,
    this.onTrialTap,
    this.unit,
    this.message,
    this.iconGradientColorList,
  });

  @override
  Widget build(BuildContext context) {
    final s = Get.width / 440;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xff1E2A3D), width: 1.25),
        borderRadius: BorderRadius.circular(16 * s),
        color: Color(0xff0F1520),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.51 * s,
                height: 46.51 * s,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.8 * s),
                  color: Color(0xffD4A574).withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  iconPath ?? "assets/icons/Lock2.png",
                  width: 24 * s,
                ),
              ),
              SizedBox(width: 12 * s),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title ?? "Your data is protected",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          fontSize: 14 * s,
                          fontWeight: FontWeight.w500,
                          color: Color(0xffE8ECF4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    description ??
                        "GDPR compliant · UAE fintech standards",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 12 * s,
                      color: const Color(0xff7B8BA5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 18 * s,),
          Row(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/FileText.png"),
                  SizedBox(width: 3 * s),
                  Text(
                    message ?? "Cancellation Policy",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 14 * s,
                      color: const Color(
                        0xff7B8BA5,
                      ).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16 * s,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/icons/HelpCircle.png"),
                  SizedBox(width: 3* s),
                  Text(
                    "How AI Work",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 14 * s,
                      color: const Color(
                        0xff7B8BA5,
                      ).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
