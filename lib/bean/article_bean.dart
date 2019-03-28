class ArticleBean {
  String author;
  String title;
  String digest;
  String content;
  int wc;
  DateBean date;

  ArticleBean({this.author, this.title, this.digest, this.content, this.wc, this.date});

  ArticleBean.fromJson(Map<String, dynamic> json) {    
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
