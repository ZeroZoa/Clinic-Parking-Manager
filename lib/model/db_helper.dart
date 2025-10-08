import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'car_info.dart';

class ParkingInfoDB {
  static final ParkingInfoDB _instance = ParkingInfoDB._internal();

  factory ParkingInfoDB() {
    return _instance;
  }

  ParkingInfoDB._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'car_info.db');

    return openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE car_info(id INTEGER PRIMARY KEY, carNumber TEXT, date TEXT, isChecked INTEGER)',
      );
    });
  }

  Future<int> insert(CarInfo carInfo) async {
    final db = await database;

    return db.insert(
      'car_info',
      carInfo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CarInfo>> getAllCarInfos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('car_info', orderBy: 'date DESC');

    return List.generate(maps.length, (i) {
      return CarInfo.fromJson(maps[i]);
    });
  }

  Future<int> updateConfirm(int? id, bool isChecked) async {
    final db = await database;
    debugPrint('$id');
    return db.update(
      'car_info',
      {'isChecked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int? id) async {
    final db = await database;

    await db.delete(
      'car_info',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CarInfo>> getAllCarInfosByCarNumber(String number) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('car_info',
        where: "carNumber LIKE '%$number%'", orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return CarInfo.fromJson(maps[i]);
    });
  }

  Future<List<CarInfo>> getAllCarInfosByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('car_info',
        where: "date LIKE '$date%'", orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return CarInfo.fromJson(maps[i]);
    });
  }

  Future<List<CarInfo>> getAllCarInfosByCarNumberAndDate(
      String number, String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('car_info',
        where: "carNumber LIKE '%$number%' AND date LIKE '$date%'",
        orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return CarInfo.fromJson(maps[i]);
    });
  }
}
