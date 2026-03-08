import 'package:flutter/material.dart';

class RecoveryOptionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String heading;
  final String description;
  final VoidCallback? onTap;

  const RecoveryOptionCard({

    super.key,
    required this.icon,
    required this.title,
    required this.heading,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        // margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffA8B3BA), width: 0.2),
          borderRadius: BorderRadius.circular(25),
          color: Color(0xff0E1215).withValues(alpha: 0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    Image.asset(
                      icon,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffffffff)
                      ),
                    ),
                  ],
                ),

                Image.asset(
                  "assets/icons/check_point.png",
                  width: 24,
                  height: 24,
                )
              ],
            ),

            const SizedBox(height: 10),

            /// Heading
            Text(
              heading,
              style: const TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xffC084FC)
              ),
            ),

            const SizedBox(height: 6),

            /// Description
            Text(
              description,
              style: const TextStyle(
                  fontFamily: "HelveticaNeue",
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xffA8B3BA)
              ),
            ),
          ],
        ),
      ),
    );
  }
}