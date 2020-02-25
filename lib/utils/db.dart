import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static final String sqlFileName = "fiora_database.db"; // sql数据文件
  final String userInfo = "userInfo"; // 用户信息

  static Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), sqlFileName),
      onCreate: (db, version) {
        return db.execute(
          '''
        CREATE TABLE users(
          id TEXT PRIMARY KEY,
          username TEXT, 
          tag TEXT,
          avatar TEXT,
          token TEXT,
          tag TEXT,
          expiryDate TEXT,
          isAdmin INTEGER,
        )
        ''',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await database();
    db.insert(
      table,
      data,
      // 如果数据库里面有相同主键的数据，则覆盖
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> deleteUser(String id, String table) async {
    // Get a reference to the database.
    final db = await database();

    // Remove user from the database.
    await db.delete(
      table,
      // Use a `where` clause to delete a specific user.
      where: "id = ?",
      // Pass the User's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
    return true;
  }

  // Future<bool> updateUser() async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   // Update the given Dog.
  //   await db.update(
  //     'dogs',
  //     dog.toMap(),
  //     // Ensure that the Dog has a matching id.
  //     where: "id = ?",
  //     // Pass the Dog's id as a whereArg to prevent SQL injection.
  //     whereArgs: [user.id],
  //   );
  //   return true;
  // }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await Db.database();
    return db.query(table);
  }
}
