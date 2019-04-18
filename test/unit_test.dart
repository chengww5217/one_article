import 'package:flutter_test/flutter_test.dart';
import 'package:one_article/utils/date_util.dart';

void main() {
  group("date_util test", () {
    test("test formatDate", (){
      DateTime dateTime01 = DateTime(2018, 1, 1);
      DateTime dateTime02 = DateTime(2018, 11, 11);
      DateTime dateTime03 = DateTime.now();
      
      String dateTime03Expect = "${dateTime03.year}${twoDigits(dateTime03.month)}${twoDigits(dateTime03.day)}";
      expect(formatDate(dateTime01), "20180101");
      expect(formatDate(dateTime02), "20181111");
      expect(formatDate(dateTime03), dateTime03Expect);
    });
    
    test("test str2Date", () {
      String date01;
      String date02 = "random";
      String date03 = "201811";
      String date04 = "20180101";

      DateTime date04Expect = DateTime(2018, 1, 1);
      expect(str2Date(date01), null);
      expect(str2Date(date02), null);
      expect(str2Date(date03), null);
      expect(str2Date(date04), date04Expect);
    });
  });

  
}