import 'package:flutter/material.dart';
import 'package:one_article/bean/article_bean.dart';
import 'package:one_article/db/database.dart';
import 'package:one_article/network/api.dart';
import 'package:one_article/utils/sp_store_util.dart';

class HomePage extends StatefulWidget {
  final ArticleBean article;

  HomePage(this.article);

  @override
  State<StatefulWidget> createState() => _HomePageState(article);
}

class _HomePageState extends State<HomePage> {
  ArticleBean article;

  _HomePageState(this.article);

  double _fontSize = 18;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getFontSize().then((value) {
      if (value != _fontSize) {
        setState(() {
          _fontSize = value;
        });
      }
    });
    if (article == null) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.data.title),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.menu), onPressed: _bottomMenu),
        actions: <Widget>[
          IconButton(
            icon: Icon(article.starred ? Icons.star : Icons.star_border),
            onPressed: onStarPress,
          )
        ],
      ),
      body: ListView(
        children: [
          Text.rich(
              TextSpan(
                  text: article.data.date == null
                      ? ""
                      : "(${article.data.date.curr}，作者：${article.data.author}，共${article.data.wc}字)",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: _fontSize - 3,
                      height: 1.4)),
              textAlign: TextAlign.end),
          InkWell(
            onTap: () {
              if (article.data.date == null) {
                loadData();
              } else {
                return true;
              }
            },
            child: Container(
              child: Text(
                article.data.content,
                style: TextStyle(fontSize: _fontSize),
                textAlign: TextAlign.start,
              ),
              color: article.data.date == null ? Colors.transparent : Theme.of(context).canvasColor,
            ),
          )
        ],
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  void onStarPress() {
    setState(() {
      article.starred = !article.starred;
      ArticleProvider().insertOrReplaceToDB(article);
    });
  }

  void _bottomMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return StatefulBuilder(
            builder: (context, mSetState) {
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "字号",
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                                child: Slider(
                              onChanged: (double value) {
                                storeFontSize(value.roundToDouble());
                                mSetState(
                                    () => _fontSize = value.roundToDouble());
                                setState(() {});
                              },
                              divisions: 16,
                              label: '${_fontSize.round()}',
                              value: _fontSize,
                              activeColor: Colors.blue,
                              min: 10,
                              max: 26,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  height: 200,
                  padding: EdgeInsets.all(8),
                ),
                onTap: () => false,
              );
            },
          );
        });
  }

  void loadData() {
    article = ArticleBean();
    article.data = DataBean();
    article.data.title = "加载中";
    article.data.content = "加载中";
    article.starred = false;
    setState(() {});
    Article.today().then((article) {
      setState(() {
        this.article = article;
      });
    }).catchError((e) {
      setState(() {
        article.data.title = "加载失败";
        article.data.content = "加载失败，请点击重试";
        this.article = article;
      });
    });
  }
}
