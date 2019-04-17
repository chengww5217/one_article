import 'dart:convert';

import 'package:one_article/bean/article_bean.dart';
import 'package:http/http.dart' as http;
import 'package:one_article/db/database.dart';
import 'package:one_article/utils/date_util.dart';
import 'package:one_article/utils/errors.dart';
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
    return await getArticle(date: "random");
  }

  static Future<ArticleBean> someday(String someday) async {
    return await getArticle(date: someday);
  }

  static Future<ArticleBean> getArticle({String date}) async {
    ArticleBean articleBean;
    String url;
    if (!strings.isEmpty(date)) {
      if ("today" == date) {
        url = "$baseUrl$todayArticle";
      } else if ("random" == date) {
        url = "$baseUrl$randomArticle";
      } else {
        url = "$baseUrl$somedayArticle$date";
        ArticleProvider provider = ArticleProvider();
        articleBean = await provider.getFromDB(date);
      }
    } else {
      url = "$baseUrl$randomArticle";
    }

    if (articleBean == null) {
      articleBean = await getRequest(url);
    }

    return articleBean;
  }

  static Future<ArticleBean> getRequest(String url) async {
    ArticleBean articleBean;
    http.Response response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode < 400) {
      try {
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
        }

        ArticleProvider provider = ArticleProvider();
        if (url.contains(randomArticle)) {
          ArticleBean local = await provider.getFromDB(articleBean.date);
          if (local != null) {
            articleBean.starred = local.starred;
          }
        }
        await provider.insertOrReplaceToDB(articleBean);
      } catch (e) {
        throw NetError(response: response, error: e);
      }
    } else {
      throw NetError(response: response);
    }
    return articleBean;
  }
}
