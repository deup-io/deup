import 'package:floor/floor.dart';

import 'package:deup/database/entity/index.dart';

@dao
abstract class ProgressDao {
  @Query(
    'SELECT * FROM progress WHERE server_id = :serverId AND object_id = :objectId',
  )
  Future<ProgressEntity?> findProgressByServerIdAndObjectId(
      String serverId, String objectId);

  @Query('DELETE FROM progress WHERE id = :id')
  Future<void> deleteProgressById(int id);

  @Query('DELETE FROM progress WHERE server_id = :serverId')
  Future<void> deleteProgressByServerId(String serverId);

  @insert
  Future<int> insertProgress(ProgressEntity progress);

  @update
  Future<int> updateProgress(ProgressEntity progress);
}
