import 'package:flutter/material.dart';
import 'package:one_article/generated/i18n.dart';
import 'package:one_article/utils/date_util.dart';

class ButtonBean {
  int id;
  String date;
  String buttonText;
  BuildContext context;

  ButtonBean(this.context, this.id, String currentDate) {
    if (id == 0) {
      DateTime today = DateTime.now();
      date = "${today.year}${twoDigits(today.month)}${twoDigits(today.day)}";
      buttonText = S.of(context).today;
    } else if (id > 1) {
      date = "random";
      buttonText = S.of(context).random;
    } else {
      DateTime current = str2Date(currentDate);
      DateTime dateTime = current.add(Duration(days: id));
      date = "${dateTime.year}${twoDigits(dateTime.month)}${twoDigits(dateTime.day)}";
      buttonText = "${id > 0 ? S.of(context).day_after : S.of(context).day_before}";
    }

  }


}