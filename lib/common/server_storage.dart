import 'dart:convert';

import 'package:deup/common/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/services/index.dart';

/// 插件存储
class ServerStorage {
  final String serverId;
  final storageDao = DatabaseService.to.database.storageDao;

  ServerStorage(this.serverId) : assert(serverId.isNotEmpty);

  /// 获取所有的存储
  ///
  /// [key] 需要获取的 key
  Future<dynamic> get(String? key) async {
    final _storage = await storageDao.findStorageByServerId(serverId);
    if (_storage == null) return null;
    final _data = json.decode(_storage.data);
    if (key == null) return _data;
    return _data[key];
  }

  /// 设置存储
  ///
  /// [key] 需要设置的 key
  /// [value] 需要设置的 value
  Future<int> set(String? key, dynamic value) async {
    final _now = DateTime.now().millisecondsSinceEpoch;
    final _storage = await storageDao.findStorageByServerId(serverId);

    // 如果没有存储则创建
    if (_storage == null) {
      return await storageDao.insertStorage(StorageEntity(
        id: CommonUtils.generateUuid(),
        createdAt: _now,
        updatedAt: _now,
        serverId: serverId,
        data: json.encode(key == null ? value : {key: value}),
      ));
    }

    // 如果有存储则更新
    final _data = json.decode(_storage.data);
    if (key != null) _data[key] = value;
    return await storageDao.updateStorage(StorageEntity(
      id: _storage.id,
      createdAt: _storage.createdAt,
      updatedAt: _now,
      serverId: _storage.serverId,
      data: json.encode(key == null ? value : _data),
    ));
  }

  /// 删除存储
  ///
  /// [key] 需要删除的 key
  Future<int> remove(String key) async {
    final _now = DateTime.now().millisecondsSinceEpoch;
    final _storage = await storageDao.findStorageByServerId(serverId);
    if (_storage == null) return 0;

    // 如果有存储则更新
    final _data = json.decode(_storage.data);
    _data.remove(key);
    return await storageDao.updateStorage(StorageEntity(
      id: _storage.id,
      createdAt: _storage.createdAt,
      updatedAt: _now,
      serverId: _storage.serverId,
      data: json.encode(_data),
    ));
  }

  /// 清空存储
  Future<void> clear() async {
    final _storage = await storageDao.findStorageByServerId(serverId);
    if (_storage == null) return;
    return await storageDao.deleteStorageByServerId(serverId);
  }
}
