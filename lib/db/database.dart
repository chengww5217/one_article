import 'dart:async';
import 'dart:io';

import 'package:one_article/bean/article_bean.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:meta/meta.dart';
import 'package:quiver/strings.dart' as strings;

class DBHelper {
  static const _VERSION = 1;
  static const _DB_NAME = "one_article.db";
  Database _db;
  final _lock = Lock();

  factory DBHelper() => _getInstance();

  static DBHelper get instance => _getInstance();
  static DBHelper _instance;

  DBHelper._internal();

  static DBHelper _getInstance() {
    if (_instance == null) {
      _instance = new DBHelper._internal();
    }
    return _instance;
  }

  Future<void> init() async {
    // DB path
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _DB_NAME);
    if (!await Directory(dirname(path)).exists()) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    _db = await openDatabase(path, version: _VERSION,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
//      await db.execute('''
//      create table article (_id integer primary key autoincrement, starred integer not null,
//          date text not null,
//          data blob not null)
//          ''');
    });
  }

  Future<bool> isTableExits(String tableName) async {
    await getDB();
    var res = await _db.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }

  Future<Database> getDB() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        // Check again once entering the synchronized block
        if (_db == null) {
          await init();
        }
      });
    }
    return _db;
  }

  void close() {
    _db?.close();
    _db = null;
  }
}

/// Base provider
abstract class BaseDBProvider {
  bool isTableExits = false;

  String createSql();

  String tableName();

  String baseCreateSql(String name, String columnId) {
    return '''
        create table $name (
        $columnId integer primary key autoincrement,
      ''';
  }

  @mustCallSuper
  Future<void> createTable(String name, String createSql) async {
    isTableExits = await DBHelper.instance.isTableExits(name);
    if (!isTableExits) {
      Database db = await DBHelper.instance.getDB();
      return await db.execute(createSql);
    }
  }

  @mustCallSuper
  Future<Database> getDB() async {
    await createTable(tableName(), createSql());
    return await DBHelper.instance.getDB();
  }
}

class ArticleProvider extends BaseDBProvider {
  /// DataBase table name
  static final String name = "article";

  static final String columnId = "_id";
  static final String columnStarred = "starred";
  static final String columnData = "data";
  static final String columnDate = "date";

  @override
  String createSql() =>
      baseCreateSql(name, columnId) +
          '''
        $columnStarred integer not null,
        $columnDate text not null,
        $columnData text not null)
      ''';

  @override
  String tableName() => name;

  Future<ArticleBean> getFromDB(String date) async {
    Database db = await getDB();
    List<Map<String, dynamic>> maps =
    await db.query(name, columns: [columnId, columnStarred, columnDate, columnData], where: "$columnDate = ?", whereArgs: [date]);
    if (maps.length > 0) {
      ArticleBean provider = ArticleBean.fromJson(maps.first);
      return provider;
    }
    return null;
  }

  Future insertOrReplaceToDB(ArticleBean article) async {
    String date = article?.date;
    if (article == null || strings.isEmpty(date)) return null;
    Database db = await getDB();
    var provider = await getFromDB(date);
    Map<String, dynamic> map = article.toMap();
    if (provider != null) {
      await db.update(name, map, where: "$columnDate = ?", whereArgs: [date]);
    }
    return await db.insert(name, map);
  }

}
