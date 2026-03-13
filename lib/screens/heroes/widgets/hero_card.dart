import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import '../../recovery_ai/widgets/option_chip.dart';
import '../controller/heroes_controller.dart';

class HeroCard extends StatelessWidget {
  final HeroModel data;

  const HeroCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final double cardHeight = 320 * s;

    final bool isFirst = data.position == "#1";
    final Color mainColor = isFirst
        ? const Color(0xffFFB547)
        : const Color(0xff81AAC0);

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * s),
        border: Border.all(color: mainColor, width: 2), // Conditional border
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13 * s),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.7,
                child: Image.asset(
                  data.heroImage,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: cardHeight / 2,
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * s,
                  vertical: 8 * s,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15 * s),
                  color: const Color(0xff151B20).withValues(alpha: 0.33),
                  border: Border(
                    top: BorderSide(color: mainColor, width: 1),
                  ), // Conditional top border
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.heroName,
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontWeight: FontWeight.w500,
                        fontSize: 18 * s,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      data.rank,
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontWeight: FontWeight.w500,
                        fontSize: 14 * s,
                        color: mainColor,
                      ),
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.legacyLabel,
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontWeight: FontWeight.w300,
                            fontSize: 14 * s,
                            color: const Color(0xff6B7680),
                          ),
                        ),
                        Text(
                          data.legacyValue,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontWeight: FontWeight.w500,
                            fontSize: 14 * s,
                            color: const Color(0xff193CAD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: OptionChip(
                backgroundColor: const Color(0xff151B20),
                borderRadius: 15,
                borderColor: mainColor,
                // Conditional chip border
                height: 28 * s,
                fontSize: 14 * s,
                fontColor: mainColor,
                // Conditional chip font color
                title: data.position,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
