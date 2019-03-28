import 'dart:convert';

import 'package:one_article/bean/article_bean.dart';
import 'package:http/http.dart' as http;
import 'package:one_article/db/database.dart';
import 'package:one_article/utils/date_util.dart';
import 'package:quiver/strings.dart' as strings;

final String baseUrl = "https://interface.meiriyiwen.com";

final String todayArticle = "/article/today?dev=1";
final String randomArticle = "/article/random?dev=1";
final String somedayArticle = "/article/day?dev=1&date=";

class Article {
  static Future<ArticleBean> today() async {
    return await getArticle(date: formatDate(DateTime.now()));
  }

  static Future<ArticleBean> random() async {
    return await getArticle();
  }

  static Future<ArticleBean> someday(String someday) async {
    return await getArticle(date: someday);
  }

  static Future<ArticleBean> getArticle({String date}) async {
    ArticleBean articleBean;
    String url;
    if (!strings.isEmpty(date)) {
      ArticleProvider provider = ArticleProvider();
      articleBean = await provider.getFromDB(date);
      if (articleBean == null) {
        url = "$baseUrl$somedayArticle$date";
        articleBean = await getRequest(url);
      }
    } else {
      url =  "$baseUrl$randomArticle";
      articleBean = await getRequest(url);
    }
    
    return articleBean;
  }

  static Future<ArticleBean> getRequest(String url) async {
    ArticleBean articleBean;
    http.Response response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode < 400) {
      Map<String, dynamic> jsonStr = json.decode(response.body);
      articleBean = ArticleBean.fromJson(jsonStr);
      DataBean data = articleBean.data;
      if (data.content != null) {
        data.content = data.content
            .replaceAll(RegExp(r"<p>|<P>"), "        ")
            .replaceAll(RegExp(r"</p>|</P>"), "\n\n");
      }
      if (data.date != null) {
        articleBean.date = data.date.curr;
        data.date.curr = getRelatedTime(str2Date(data.date.curr));
      }
      ArticleProvider provider = ArticleProvider();
      await provider.insertOrReplaceToDB(articleBean);
    }
    return articleBean;
  }
}
