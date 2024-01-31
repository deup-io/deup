import 'package:floor/floor.dart';

import 'package:deup/database/entity/index.dart';

@dao
abstract class StorageDao {
  @Query('SELECT * FROM storage WHERE server_id = :serverId')
  Future<StorageEntity?> findStorageByServerId(String serverId);

  @Query('DELETE FROM storage WHERE server_id = :serverId')
  Future<void> deleteStorageByServerId(String serverId);

  @insert
  Future<int> insertStorage(StorageEntity storage);

  @update
  Future<int> updateStorage(StorageEntity storage);
}
