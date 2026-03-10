import 'package:flutter/material.dart';

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
    const TextStyle titleStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xffC084FC),
    );

    TextStyle subTextStyle = TextStyle(
      fontFamily: "HelveticaNeue",
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xffA8B3BA),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xffC084FC),
          width:  1,
        ),
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xff0E1215).withOpacity(0.1),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
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

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),

                  const SizedBox(height: 8),

                  // 2. Goal
                  Text("Goal: $goal", style: subTextStyle.copyWith(color: Colors.white70)),

                  const SizedBox(height: 12),

                  // 3. Benefits List
                  // Inside DayWiseRecoveryCard Column children:

                  ...List.generate(benefits.length, (index) {
                    final isFirstItem = index == 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "• ",
                              style: TextStyle(
                                color: isFirstItem ? const Color(0xffC084FC) : const Color(0xffA8B3BA),
                                fontSize: 18,
                              )
                          ),
                          Expanded(
                            child: Text(
                              benefits[index],
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isFirstItem ? const Color(0xffC084FC) : const Color(0xffA8B3BA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),


                  const SizedBox(height: 20), // Bottom padding for spacing between cards
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
