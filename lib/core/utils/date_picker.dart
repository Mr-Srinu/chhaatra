import 'package:flutter/material.dart';

class DatePicker {
  Future<String> ShowDatePick() async {
    TextEditingController dateController = TextEditingController();

    DateTime intial = DateTime.now();
    DateTime first = DateTime(1990);
    DateTime last = DateTime.now();

    final DateTime? picked = CalendarDatePicker(
      lastDate: last,
      currentDate: intial,
      firstDate: first,
      initialDate: intial,
      onDateChanged: (DateTime value) {
        dateController.text = value.toString();
      },
    ) as DateTime?;
    return dateController.text;
  }
}

class DatePickerUtil {
  static Future<DateTime?> pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2030),
    );
  }
}
