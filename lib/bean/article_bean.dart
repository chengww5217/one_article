import 'dart:convert' as Json;
class ArticleBean {
  DataBean data;
  bool starred;
  String date;

  ArticleBean({this.data, this.starred = false, this.date});

  ArticleBean.fromJson(Map<String, dynamic> json) {
    bool starred;
    if (json['starred'] == null) starred = false;
    else if (json['starred'] > 0) starred = true;
    else starred = false;
    this.starred = starred;
    this.date = json['date'];
    this.data = json['data'] != null ? DataBean.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['starred'] = this.starred ? 1 : 0;
    data['date'] = this.date;
    return data;
  }

  /// For database usage
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = Json.json.encode(this.data.toJson());
    }
    data['starred'] = this.starred ? 1 : 0;
    data['date'] = this.date;
    return data;
  }

}

class DataBean {
  String author;
  String title;
  String digest;
  String content;
  int wc;
  DateBean date;

  DataBean(
      {this.author, this.title, this.digest, this.content, this.wc, this.date});

  DataBean.fromJson(dynamic jsonDynamic) {
    Map<String, dynamic> json;
    if (jsonDynamic is Map) {
      json = jsonDynamic;
    } else {
      json = Json.json.decode(jsonDynamic);
    }
    this.author = json['author'];
    this.title = json['title'];
    this.digest = json['digest'];
    this.content = json['content'];
    this.wc = json['wc'];
    this.date = json['date'] != null ? DateBean.fromJson(json['date']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['author'] = this.author;
    data['title'] = this.title;
    data['digest'] = this.digest;
    data['content'] = this.content;
    data['wc'] = this.wc;
    if (this.date != null) {
      data['date'] = this.date.toJson();
    }
    return data;
  }
}

class DateBean {
  String curr;
  String prev;
  String next;

  DateBean({this.curr, this.prev, this.next});

  DateBean.fromJson(Map<String, dynamic> json) {
    this.curr = json['curr'];
    this.prev = json['prev'];
    this.next = json['next'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['curr'] = this.curr;
    data['prev'] = this.prev;
    data['next'] = this.next;
    return data;
  }
}
