import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePicker{

  Future<String> ShowDatePick() async{
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