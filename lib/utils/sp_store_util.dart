import 'package:shared_preferences/shared_preferences.dart';

final String fontSizeKey = "fontSize";

storeFontSize(double value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble(fontSizeKey, value);
}

Future<double> getFontSize() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(fontSizeKey) ?? 18;
}