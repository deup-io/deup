import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:deup/database/dao/index.dart';
import 'package:deup/database/entity/index.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 2, entities: [
  PluginEntity,
  ServerEntity,
  HistoryEntity,
  StorageEntity,
  DownloadEntity,
  ProgressEntity,
])
abstract class DeupDatabase extends FloorDatabase {
  PluginDao get pluginDao;
  ServerDao get serverDao;
  HistoryDao get historyDao;
  StorageDao get storageDao;
  DownloadDao get downloadDao;
  ProgressDao get progressDao;
}
