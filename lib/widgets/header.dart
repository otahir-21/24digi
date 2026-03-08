import 'package:flutter/material.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

class RecoveryHeaderWidget extends StatelessWidget {
  final VoidCallback? onBackTap;

  const RecoveryHeaderWidget({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20,
      children: [
        GradientBorderWrapper(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    /// Back Arrow
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 35.0),
                        child: GestureDetector(
                          onTap: onBackTap,
                          child: Image.asset(
                            "assets/icons/back_icon.png",
                            width: 16,
                          ),
                        ),
                      ),
                    ),

                    /// Center Logo
                    Image.asset(
                      "assets/24 logo.png",
                      width: 64,
                    ),
                    /// Profile
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xff3B709A), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundImage:
                        AssetImage("assets/images/profile_img.jpg"),
                      ),
                    )
                  ],
                ),
              ),
            ),
        const Text(
          "HI, USER",
          style: TextStyle(
            fontFamily: "HelveticaNeue",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xffE1E1E1),
          ),
        ),
      ],
    );
  }
}