import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class DayWiseRecoveryCard extends StatelessWidget {
  final String title;
  final String goal;
  final List<String> benefits;

  const DayWiseRecoveryCard({
    super.key,
    required this.title,
    required this.goal,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
      TextStyle titleStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontSize: 24* s,
      fontWeight: FontWeight.w700,
      color: Color(0xffC084FC),
    );

    TextStyle subTextStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontSize: 16* s,
      fontWeight: FontWeight.w500,
      color: Color(0xffA8B3BA),
    );

    return Container(
      padding:   EdgeInsets.symmetric(horizontal: 18* s, vertical: 20* s),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffC084FC),
          width:  1,
        ),
        borderRadius: BorderRadius.circular(25* s),
        color: const Color(0xff0E1215).withOpacity(0.1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12* s,
                  height: 12* s,
                  decoration: const BoxDecoration(
                    color: Color(0xffC084FC),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xff26313A),
                  ),
                ),
              ],
            ),

              SizedBox(width: 16* s),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),

               SizedBox(height: 8* s),

                  // 2. Goal
                  Text("Goal: $goal", style: subTextStyle.copyWith(color: Colors.white70)),

                    SizedBox(height: 12* s),

                  // 3. Benefits List
                  // Inside DayWiseRecoveryCard Column children:

                  ...List.generate(benefits.length, (index) {
                    final isFirstItem = index == 0;

                    return Padding(
                      padding:  EdgeInsets.only(bottom: 6.0* s),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "• ",
                              style: TextStyle(
                                color: isFirstItem ? const Color(0xffC084FC) : const Color(0xffA8B3BA),
                                fontSize: 18* s,
                              )
                          ),
                          Expanded(
                            child: Text(
                              benefits[index],
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: 16* s,
                                fontWeight: FontWeight.w500,
                                color: isFirstItem ? const Color(0xffC084FC) : const Color(0xffA8B3BA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),


                    SizedBox(height: 20* s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
