import 'dart:convert';

import 'package:one_article/bean/article_bean.dart';
import 'package:http/http.dart' as http;

final String baseUrl = "https://interface.meiriyiwen.com";

final String todayArticle = "/article/today?dev=1";
final String randomArticle = "/article/random?dev=1";
final String somedayArticle = "/article/day?dev=1&date=";

class Article {
  static Future<ArticleBean> today() async {
    final String url = "$baseUrl$todayArticle";
    return await getRequest(url);
  }

  static Future<ArticleBean> random() async {
    final String url = "$baseUrl$randomArticle";
    return await getRequest(url);
  }

  static Future<ArticleBean> someday(String someday) async {
    final String url = "$baseUrl$somedayArticle$someday";
    return await getRequest(url);
  }

  static Future<ArticleBean> getRequest(String url) async {
    http.Response response = await http.get(url);
    ArticleBean articleBean;
    if (response.statusCode >= 200 && response.statusCode < 400) {
      Map<String, dynamic> jsonStr = json.decode(response.body);
      articleBean = ArticleBean.fromJson(jsonStr['data']);
      if (articleBean.content != null) {
        articleBean.content = articleBean.content
            .replaceAll(RegExp(r"<p>|<P>"), "        ")
            .replaceAll(RegExp(r"</p>|</P>"), "\n\n");
      }
    }
    return articleBean;
  }
}
