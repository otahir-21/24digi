import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendationsWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final String description;
  final String price;
  final String? unit;
  final String? message;
  final List<Color>? iconGradientColorList;
  final VoidCallback? onTrialTap;

  const RecommendationsWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.price,
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
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.51 * s,
            height: 46.51 * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.8 * s),
              gradient: LinearGradient(
                begin: AlignmentGeometry.topCenter,
                end: AlignmentGeometry.bottomCenter,
                colors:
                    iconGradientColorList ??
                    [Color(0xffFF6900), Color(0xffE17100)],
              ),
            ),
            alignment: Alignment.center,
            child: Image.asset(iconPath, width: 24 * s),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: "HelveticaNeue",
                                  fontSize: 16 * s,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xffE8ECF4),
                                ),
                              ),
                              // SizedBox(width: 8 * s,),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: 14.92 * s,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: price,
                                      style: TextStyle(color: const Color(0xffE8ECF4)),
                                    ),
                                    TextSpan(
                                      text: unit ?? " AED/mo",
                                      style: TextStyle(
                                        fontSize: 14.8 * s,
                                        color: const Color(0xff7B8BA5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2 * s,),
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 14 * s,
                              color: const Color(0xff7B8BA5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * s),

                Container(
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * s),
                    border: Border.all(
                      color: const Color(0xffD4A574).withValues(alpha: 0.1),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xffD4A574).withValues(alpha: 0.05),
                        const Color(0xffD4A574).withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset("assets/icons/Lightbulb.png", width: 16 * s),
                      SizedBox(width: 8 * s),
                      Expanded(
                        child: Text(
                          message ?? "",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 12 * s,
                            color: const Color(
                              0xffD4A574,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8 * s),

                GestureDetector(
                  onTap: onTrialTap,
                  child: Text(
                    "Start Free Trial \u2794",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffD4A574),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
