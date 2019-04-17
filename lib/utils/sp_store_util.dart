import 'package:shared_preferences/shared_preferences.dart';

final String fontSizeKey = "fontSize";
final String themeColorKey = "themeColor";

Future<void> storeFontSize(double value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble(fontSizeKey, value);
}

Future<double> getFontSize() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getDouble(fontSizeKey) ?? 18;
}

Future<void> storeThemeColor(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(themeColorKey, value);
}

Future<int> getThemeColor() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt(themeColorKey) ?? 0;
}

