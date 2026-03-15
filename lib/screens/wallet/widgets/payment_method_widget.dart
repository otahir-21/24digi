// import 'package:flutter/material.dart';
// import 'package:kivi_24/core/utils/ui_scale.dart';
//
// class PaymentMethodWidget extends StatelessWidget {
//   final Color? cardBorderColor;
//   final Color? cardColor;
//   final double? topBorderWidth;
//   final String title;
//   final double? titleFontSize;
//   final FontWeight? titleFontWeight;
//   final Color? titleFontColor;
//   final double? spaceBeforeDescription;
//   final String? description;
//   final double? descriptionFontSize;
//   final Color? descriptionFontColor;
//
//   final String? prefixIcon;
//   final bool prefixIconWithBase;
//   final Color? iconBgColor;
//   final Color? iconBorderColor;
//   final Gradient? iconGradient;
//   final Color? iconImageColor;
//   final double? iconBorderRadius;
//
//   final String? points;
//   final String? status;
//   final Color? statusColor;
//   final Color? statusBgColor;
//   final String? suffixIcon;
//
//   // New Optional Properties for Right Side
//   final String? statusIcon;
//   final Color? pointsColor;
//
//   final double? horizontalPadding;
//   final double? verticalPadding;
//   final CrossAxisAlignment? crossAxisAlignment;
//
//   const RecentActivityCard({
//     super.key,
//     required this.title,
//     this.prefixIcon,
//     this.description,
//     this.iconBgColor,
//     this.iconGradient,
//     this.titleFontSize,
//     this.titleFontWeight,
//     this.cardBorderColor,
//     this.topBorderWidth,
//     this.titleFontColor,
//     this.prefixIconWithBase = true,
//     this.iconBorderColor,
//     this.descriptionFontColor,
//     this.spaceBeforeDescription,
//     this.descriptionFontSize,
//     this.iconImageColor,
//     this.iconBorderRadius,
//     this.cardColor,
//     this.points,
//     this.status,
//     this.statusIcon, // New
//     this.statusColor, // New
//     this.pointsColor,
//     this.suffixIcon,
//     this.horizontalPadding,
//     this.verticalPadding,
//     this.statusBgColor, this.crossAxisAlignment, // New
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final s = UIScale.of(context);
//
//     final Color finalPointsColor =
//         pointsColor ??
//             ((points?.startsWith("-") ?? false)
//                 ? const Color(0xffF472B6)
//                 : const Color(0xFF00D4AA));
//
//     return Container(
//       padding: EdgeInsetsGeometry.symmetric(
//         horizontal: horizontalPadding ?? 0,
//         vertical: verticalPadding ?? 0,
//       ),
//       decoration: BoxDecoration(
//         border: Border.all(color: cardBorderColor ?? Colors.transparent),
//         borderRadius: BorderRadius.circular(16 * s),
//         color: cardColor ?? Colors.transparent,
//       ),
//       child: Row(
//         crossAxisAlignment: crossAxisAlignment?? CrossAxisAlignment.center,
//         children: [
//           if (prefixIcon != null)
//             prefixIconWithBase
//                 ? Container(
//               width: 46.51 * s,
//               height: 46.51 * s,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: iconBorderColor ?? Colors.transparent,
//                 ),
//                 borderRadius: BorderRadius.circular(
//                   iconBorderRadius ?? 17 * s,
//                 ),
//                 color: iconBgColor,
//                 gradient: iconGradient,
//               ),
//               child: Image.asset(prefixIcon ?? "", color: iconImageColor),
//             )
//                 : Image.asset(prefixIcon ?? ""),
//           SizedBox(width: 12 * s),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontFamily: "HelveticaNeue",
//                     fontSize: titleFontSize ?? 15 * s,
//                     fontWeight: titleFontWeight ?? FontWeight.w500,
//                     color: titleFontColor ?? const Color(0xffffffff),
//                   ),
//                 ),
//                 if (description != null) ...[
//                   SizedBox(height: spaceBeforeDescription),
//                   Text(
//                     description!,
//                     style: TextStyle(
//                       fontFamily: "HelveticaNeue",
//                       fontSize: descriptionFontSize ?? 12 * s,
//                       fontWeight: FontWeight.w500,
//                       color: descriptionFontColor ?? const Color(0xff7B8BA5),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           SizedBox(width: 2 * s),
//           if (suffixIcon != null) Image.asset(suffixIcon!),
//           if (status != null)
//             Container(
//               padding: EdgeInsetsGeometry.symmetric(horizontal: 10 * s),
//               height: 18 * s,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: statusBgColor, // Red for urgent
//                 borderRadius: BorderRadius.circular(15 * s),
//               ),
//               child: Text(
//                 status!,
//                 style: TextStyle(
//                   fontSize: 9 * s,
//                   fontWeight: FontWeight.w500,
//                   color: statusColor,
//                 ),
//               ),
//             ),
//           if (points != null)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   points ?? "",
//                   style: TextStyle(
//                     fontFamily: "HelveticaNeue",
//                     color: finalPointsColor,
//                     fontSize: 15 * s,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset(statusIcon ?? "assets/icons/verified_icon.png"),
//                     SizedBox(width: 4 * s),
//                     Text(
//                       "Verified",
//                       style: TextStyle(
//                         fontFamily: "HelveticaNeue",
//                         color: const Color(0xFF00D4AA).withValues(alpha: 0.4),
//                         fontSize: 8 * s,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }
