import 'package:flutter/material.dart';
import 'package:one_article/bean/article_bean.dart';
import 'package:one_article/db/database.dart';
import 'package:one_article/generated/i18n.dart';
import 'package:one_article/utils/date_util.dart';

class StarredListPage extends StatefulWidget {
  final Color _themeColor;

  StarredListPage(this._themeColor);

  @override
  State<StatefulWidget> createState() => _StarredListPageState(_themeColor);
}

class _StarredListPageState extends State<StarredListPage> {
  final Color _themeColor;
  List<ArticleBean> _articles = [];
  ArticleProvider provider;

  _StarredListPageState(this._themeColor);

  @override
  void initState() {
    provider = ArticleProvider();
    provider.getStarred().then((articles) {
      setState(() => _articles = articles);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: _themeColor);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).action_starred_list),
        actions: <Widget>[
          IconButton(
            icon: Icon(_articles.length > 0 ? Icons.delete : null),
            onPressed: () {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text(S.of(context).title_clear_starred),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(S.of(context).action_cancel, style: style,),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                FlatButton(
                                  child: Text(S.of(context).action_ok, style: style,),
                                  onPressed: () {
                                    provider
                                        .clearStarred()
                                        .then((_) => provider.getStarred())
                                        .then((articles) {
                                      setState(() => _articles = articles);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ));
                  },
          )
        ],
        backgroundColor: _themeColor,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_articles.length < 1) {
      return Center(
        child: Text(
          S.of(context).content_not_starred,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(itemBuilder: (context, index) {
      final total = _articles.length * 2;
      if (index <= total) {
        if (index.isOdd) return Divider();
        final i = index ~/ 2;

        if (i < _articles.length) {
          DataBean data = _articles[i].data;
          return ListTile(
            title: Text(data.title),
            subtitle: Text("${data.author} - ${getRelatedTime(context, str2Date(data.date.curr))}"),
            trailing: IconButton(icon: Icon(Icons.delete), color: Colors.black45,
                onPressed: () {
              _articles[i].starred = false;
              provider.insertOrReplaceToDB(_articles[i]).then((_) {
                setState(() => _articles.removeAt(i));
              });
            }),
            onTap: () {
              Navigator.pop(context, _articles[i]);
            },
          );
        }
      }
    });
  }
}
