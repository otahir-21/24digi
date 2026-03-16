import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/heroes/controller/heroes_controller.dart';
import 'package:kivi_24/screens/heroes/views/hero_profile.dart';
import 'package:kivi_24/screens/heroes/views/hero_recognized.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../widgets/hero_card.dart';

class Heroes extends StatelessWidget {
  Heroes({super.key});

  final controller = Get.put(HeroesController());

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Scaffold(
      // backgroundColor: Color(0xff0E1215),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xff2B3453), Color(0xff0C0F1D)],
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RecoveryHeaderWidget(
                onBackTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(height: 30 * s),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 30 * s,),
                    Text(
                      "24 HEROES",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 56 * s,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xffFFB547),
                        shadows: [
                          Shadow(
                            color: const Color(0xffFFB547), // Shadow color
                            offset: const Offset(0, 0), // 0px 0px
                            blurRadius: 18.0 * s, // 10px blur (scaled)
                          ),
                        ],
                      ),
                    ),

                    Center(
                      child: Text(
                        "Those who set the standard for discipline and legacy",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff6B7680),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HeroRecognized(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.info_outline,
                          color: Color(0xffFFB547),
                        ),
                      ),
                    ),
                    SizedBox(height: 6 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OptionChip(
                          backgroundColor: Color(0xff2B3453),
                          borderColor: Color(0xffFFB547),
                          borderRadius: 15 * s,
                          title: "All Heroes",
                          fontSize: 14 * s,
                          isSelected: false,
                          onTap: () {},
                        ),
                        OptionChip(
                          backgroundColor: Color(0xff2B3453),
                          borderColor: Color(0xffFFB547),
                          borderRadius: 15 * s,
                          title: "Discipline",
                          fontSize: 14 * s,
                          isSelected: false,
                          onTap: () {},
                        ),
                        OptionChip(
                          backgroundColor: Color(0xff2B3453),
                          borderColor: Color(0xffFFB547),
                          borderRadius: 15 * s,
                          title: "Health",
                          fontSize: 14 * s,
                          isSelected: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 47 * s),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 46 * s,
                        mainAxisSpacing: 12 * s,
                        mainAxisExtent: 320 * s,
                      ),

                      itemCount: controller.heroes.length,
                      itemBuilder: (context, index) {
                        final hero = controller.heroes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HeroProfile(),
                              ),
                            );
                          },
                          child: HeroCard(data: hero),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
