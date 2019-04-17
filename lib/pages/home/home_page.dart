import 'package:flutter/material.dart';
import 'package:one_article/bean/article_bean.dart';
import 'package:one_article/db/database.dart';
import 'package:one_article/generated/i18n.dart';
import 'package:one_article/network/api.dart';
import 'package:one_article/pages/home/bottom_settings.dart';
import 'package:one_article/pages/starred_list/starred_list_page.dart';
import 'package:one_article/utils/constant.dart';
import 'package:one_article/utils/date_util.dart';
import 'package:one_article/utils/sp_store_util.dart';

class HomePage extends StatefulWidget {
  final ArticleBean article;

  HomePage(this.article);

  @override
  State<StatefulWidget> createState() => _HomePageState(article);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  ArticleBean article;
  String date = formatDate(DateTime.now());

  _HomePageState(this.article);

  double _fontSize = 18;
  TabController _tabController;
  int _themeColorIndex = 0;
  ArticleProvider provider;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);
    provider = ArticleProvider();
    getFontSize()
        .then((value) {
          if (value != _fontSize) {
            _fontSize = value;
          }
        })
        .then((value) => getThemeColor())
        .then((value) {
          if (value != _themeColorIndex) {
            setState(() {
              _themeColorIndex = value;
              _tabController.index = value;
            });
          }
        });
  }

  @override
  void didChangeDependencies() {
    // S.of(context) must call after _HomePageState.initState() completed.
    if (article == null) {
      loadData(date);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    provider.getDB().then((db) => db.close());
    super.dispose();
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
            onPressed: onStarPressed,
          )
        ],
        backgroundColor: themeColors[_themeColorIndex],
      ),
      body: ListView(
        children: [
          Text.rich(
            TextSpan(
                text: article?.data?.date == null
                    ? ""
                    : "(${getRelatedTime(context, str2Date(article.data.date.curr))}，${S.of(context).author}：${article.data.author}，${S.of(context).word_count}：${article.data.wc})",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: _fontSize - 3,
                  height: 1.4,
                )),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          InkWell(
            onTap: () {
              if (article?.data?.date == null) {
                loadData(date);
              } else {
                return true;
              }
            },
            child: Container(
              child: Text(
                article?.data?.content,
                style: TextStyle(fontSize: _fontSize),
                textAlign: TextAlign.start,
              ),
              color: article.data.date == null
                  ? Colors.transparent
                  : Theme.of(context).canvasColor,
            ),
          )
        ],
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  void onStarPressed() {
    provider.insertOrReplaceToDB(article);
    setState(() {
      article.starred = !article.starred;
    });
  }

  void _bottomMenu() {
    BottomSettings bottom = BottomSettings(context);
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      bottom.fontSizeSelector(_fontSize, _themeColorIndex,
                          (value) {
                        double valueRound = value.roundToDouble();
                        storeFontSize(valueRound);
                        mSetState(() => _fontSize = valueRound);
                        setState(() => _fontSize = valueRound);
                      }), // Font size set
                      bottom.themeSelector(_tabController, _themeColorIndex,
                          (value) {
                        storeThemeColor(value);
                        setState(() {
                          _themeColorIndex = value;
                        });
                        mSetState(() {});
                      }), // Theme color set
                      bottom.articleChange(themeColors[_themeColorIndex], date,
                          (date) {
                        loadData(date);
                        Navigator.of(context).pop();
                      }),
                      bottom.starredList(article?.starred,
                          themeColors[_themeColorIndex], () {
                        onStarPressed();
                        mSetState(() {});
                      }, () {
                        // Push and replace current bottom dialog
                        Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StarredListPage(
                                        themeColors[_themeColorIndex])))
                            .then((result) {
                          if (result is ArticleBean) {
                            // Clicked a starred article and back
                            setState(() {
                              article = result;
                              date = article.date;
                            });
                          } else {
                            // Normally back, check current article's starred state
                            provider
                                .getFromDB(article.date)
                                .then((articleBean) {
                              if (articleBean != null &&
                                  articleBean.starred != article.starred) {
                                setState(() =>
                                    article.starred = articleBean.starred);
                              }
                            });
                          }
                        });
                      }),
                      Container(
                        height: 20,
                      )
                    ],
                  ),
                  height: 250,
                  padding: EdgeInsets.all(10),
                ),
                onTap: () => false,
              );
            },
          );
        });
  }

  void loadData(String date) {
    article = ArticleBean();
    article.data = DataBean();
    if (date != "random") {
      this.date = date;
    }
    article.data.title = S.of(context).action_loading;
    article.data.content = S.of(context).action_loading;
    article.starred = false;
    setState(() {});
    Article.getArticle(date: date).then((article) {
      setState(() {
        this.date = article.date;
        this.article = article;
      });
    }).catchError((e) {
      setState(() {
        article.data.title = S.of(context).action_load_error;
        article.data.content = S.of(context).content_load_error;
        this.article = article;
      });
    });
  }
}
