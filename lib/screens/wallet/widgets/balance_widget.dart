import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool isHidden = false;

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Container(
      // height: 224 * s,
      padding: EdgeInsets.all(18 * s),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25 * s),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
          width: 1.27 * s,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111125), Color(0xFF0D1520), Color(0xFF0A0F18)],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// TITLE + EYE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "TOTAL BALANCE",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: Color(0xFF8888A0),
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(width: 6 * s),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isHidden = !isHidden;
                          });
                        },
                        child: Icon(
                          isHidden
                              ? CupertinoIcons.eye_slash
                              : Icons.remove_red_eye_outlined,
                          size: 20 * s,
                          color: Color(0xFF8888A0),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isHidden ? "******" : "12,500",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: Colors.white,
                      fontSize: 36 * s,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "≈ AED 12,500",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      color: Color(0xFF555568),
                      fontSize: 12 * s,
                    ),
                  ),
                ],
              ),
              Image.asset("assets/images/digi_point.png", height: 138 * s),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * s,
                  vertical: 4 * s,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffFBBF24).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20 * s),
                  border: Border.all(
                    color: Color(0xffFBBF24).withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  spacing: 4 * s,
                  children: [
                    Image.asset("assets/icons/Icon (10).png"),
                    Text(
                      "Elite",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        color: Color(0xffFBBF24),
                        fontWeight: FontWeight.w500,
                        fontSize: 10 * s,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// DIVIDER
          Container(height: 1, color: Colors.white.withOpacity(0.08)),

          SizedBox(height: 10 * s),

          /// BOTTOM INFO
          Row(
            children: [
              /// CIRCLE ICON
              CircleIcon(
                height: 28 * s,
                width: 28 * s,
                icon: "assets/icons/TrendingUp.png",
              ),
              SizedBox(width: 10 * s),

              Text(
                "+ 420",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: Color(0xFF00D4AA),
                  fontSize: 12 * s,
                ),
              ),
              SizedBox(width: 9 * s),
              Text(
                "this week",
                style: TextStyle(
                  fontFamily: "HelveticaNeue",
                  color: Color(0xFF8888A0),
                  fontSize: 10 * s,
                ),
              ),

              SizedBox(width: 17 * s),

              Container(
                width: 17 * s,
                height: 13 * s,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Color(0xffFFFFFF).withValues(alpha: 0.6),
                    ),
                    right: BorderSide(
                      color: Color(0xffFFFFFF).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 17 * s),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF555568),
                  ),
                  children: const [
                    TextSpan(
                      text: "14d",
                      style: TextStyle(color: Color(0xffF472B6)),
                    ),
                    TextSpan(
                      text: ' streak',
                      style: TextStyle(color: Color(0xFF4A5A64)),
                    ),
                  ],
                ),
              ),
              // Text(
              //   "14d streak",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 12 * s,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
