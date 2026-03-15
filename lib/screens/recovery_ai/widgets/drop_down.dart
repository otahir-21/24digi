import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

final List<String> items = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
final valueListenable = ValueNotifier<String?>(null);

class DropDown extends StatelessWidget {
  const DropDown({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: valueListenable,
      builder: (context, selectedValue, _) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            valueListenable: valueListenable,
            hint: Text(
              "Select days",
              style: TextStyle(
                fontFamily: "HelveticaNeueLight",
                fontSize: 14 * s,
                fontWeight: FontWeight.w400,
                color: const Color(0xff6B7680),
              ),
            ),
            items: items
                .map(
                  (String item) => DropdownItem<String>(
                    value: item,
                    height: 40 * s,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              valueListenable.value = value;
            },
            buttonStyleData: ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16 * s),
              height: 62 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25 * s),
                border: Border.all(color: Color(0xffC084FC), width: 1),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xffA8B3BA)),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200 * s,
              width: 280 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14 * s),
                color: Color(0xff000300).withValues(alpha: 0.7),
              ),
              offset: const Offset(10, -5),
              scrollbarTheme: ScrollbarThemeData(
                radius: Radius.circular(40 * s),
                thickness: WidgetStateProperty.all(6 * s),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
          ),
        );
      },
    );
  }
}
