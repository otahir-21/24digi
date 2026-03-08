import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';

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
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff6B7680),
              ),
            ),
            items: items.map((String item) => DropdownItem<String>(
              value: item,
              height: 40,
              child: Text(item),
            )).toList(),
            onChanged: (String? value) {
              valueListenable.value = value;
            },
            buttonStyleData: ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Color(0xffC084FC),
                  width: 1
                )
              )
            ),
            iconStyleData: IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down, color: Color(0xffA8B3BA),)
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Color(0xff000300).withValues(alpha: 0.7),
              ),
              offset: const Offset(10, -5),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
          ),
        );
      },
    );
  }
}


