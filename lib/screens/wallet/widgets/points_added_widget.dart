import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';

class PointsAddedWidget extends StatefulWidget {
  const PointsAddedWidget({super.key});

  @override
  State<PointsAddedWidget> createState() => _PointsAddedWidgetState();
}

class _PointsAddedWidgetState extends State<PointsAddedWidget> {
  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      // height: 224 * s,
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        color: Color(0xffFFFFFF).withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(25 * s),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.27 * s,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// TITLE + EYE
          Column(
             mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Points Added",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: const Color(0xFF8888A0),
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "+2,500",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: const Color(0xff00D4AA),
                          fontSize: 32 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8 * s),
                  Image.asset(
                    "assets/images/digi_point.png",
                    height: 55 * s,
                    width: 55 * s,
                  ),
                ],
              ),
              Text(
                "Including 250 Bonus points",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: const Color(0xFFFBBF24),
                  fontSize: 12 * s,
                ),
              ),
            ],
          ),
          SizedBox(height: 17 * s,),
          /// DIVIDER
          Container(height: 1, color: Colors.white.withOpacity(0.06)),

          SizedBox(height: 17 * s),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "New Balance",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: const Color(0xFF8888A0),
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "15,597 PTS",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: const Color(0xffFFFFFF),
                      fontSize: 21 * s,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8 * s),
              Image.asset(
                "assets/images/digi_point.png",
                height: 55 * s,
                width: 55 * s,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
