import 'package:flutter/material.dart';
import 'package:one_article/generated/i18n.dart';

String getRelatedTime(BuildContext context, DateTime date) {
  int subDay = DateTime.now().day - date?.day;

  if (subDay >= 0) {
    if (subDay < 1) {
      return S.of(context).today;
    } else if (subDay < 2) {
      return S.of(context).yesterday;
    }
  }
  return formatDate(date);
}

/// Format date as "yyyymmdddd"
String formatDate(DateTime date) {
  if (date == null) date = DateTime.now();
  return "${date.year}${twoDigits(date.month)}${twoDigits(date.day)}";
}

DateTime str2Date(String dateStr) {
  if (dateStr == null || dateStr.length != 8) return null;
  try {
    int year = int.parse(dateStr.substring(0, 4));
    int month = int.parse(dateStr.substring(4, 6));
    int day = int.parse(dateStr.substring(6));
    return DateTime(year, month, day);
  } catch (e) {
    return null;
  }
}

String twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}
