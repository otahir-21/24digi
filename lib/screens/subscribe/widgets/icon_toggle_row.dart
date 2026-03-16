import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IconToggleRow extends StatelessWidget {
  final String iconPath;
  final String title;
  final Color? titleFontColor;
  final RxBool? isSwitched;
  final Function(bool)? onToggle;
  final Widget? suffixIcon;

  const IconToggleRow({
    super.key,
    required this.iconPath,
    required this.title,
    this.isSwitched,
    this.onToggle,
    this.suffixIcon,
    this.titleFontColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 440;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * s),
      child: Row(
        children: [
          // Prefix Icon Image
          Image.asset(
            iconPath,
            width: 24 * s,
            height: 24 * s,
          ),
          SizedBox(width: 12 * s),

          // Text Right After Icon
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "HelveticaNeue",
                fontWeight: FontWeight.w500,
                fontSize: 14.8 * s,
                color: titleFontColor??  const Color(0xffE8ECF4),
              ),
            ),
          ),

          // Conditional Toggle Logic
          if (isSwitched != null)
            Obx(
                  () => CupertinoSwitch(
                value: isSwitched!.value,
                activeColor: const Color(0xffD4A574),
                trackColor: const Color(0xff1A2233),
                thumbColor: const Color(0xffFFFFFF),
                onChanged: (value) {
                  isSwitched!.value = value;
                  if (onToggle != null) onToggle!(value);
                },
              ),
            )
          else if (suffixIcon != null)
            suffixIcon!,
        ],
      ),
    );
  }
}
