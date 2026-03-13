import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

class RecoveryHeaderWidget extends StatelessWidget {
  final VoidCallback? onBackTap;

  const RecoveryHeaderWidget({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Column(
      spacing: 20* s,
      children: [
        GradientBorderWrapper(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 28.0 * s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// Back Arrow
                    CircleAvatar(
                      radius: 25 * s,
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding:  EdgeInsets.only(right: 35.0 * s),
                        child: GestureDetector(
                          onTap: onBackTap,
                          child: Image.asset(
                            "assets/icons/back_icon.png",
                            width: 16 * s,
                          ),
                        ),
                      ),
                    ),

                    Image.asset(
                      "assets/24 logo.png",
                      width: 64 * s,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xff3B709A), width: 2),
                      ),
                      child:  CircleAvatar(
                        radius: 25 * s,
                        backgroundImage:
                        AssetImage("assets/images/profile_img.jpg"),
                      ),
                    )
                  ],
                ),
              ),
            ),
         Text(
          "HI, USER",
          style: TextStyle(
            fontFamily: "HelveticaNeue",
            fontSize: 16 * s,
            fontWeight: FontWeight.w500,
            color: Color(0xffE1E1E1),
          ),
        ),
      ],
    );
  }
}