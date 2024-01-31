import 'package:floor/floor.dart';

import 'package:deup/database/entity/index.dart';

@dao
abstract class HistoryDao {
  @Query(
    'SELECT * FROM history WHERE server_id = :serverId ORDER BY updated_at DESC LIMIT :limit OFFSET :offset',
  )
  Future<List<HistoryEntity>> findHistoryByServerId(
      String serverId, int limit, int offset);

  @Query(
    'SELECT * FROM history WHERE server_id = :serverId AND object_id = :objectId',
  )
  Future<HistoryEntity?> findHistoryByServerIdAndObjectId(
      String serverId, String objectId);

  @Query('DELETE FROM history WHERE id = :id')
  Future<void> deleteHistoryById(int id);

  @Query('DELETE FROM history WHERE server_id = :serverId')
  Future<void> deleteHistoryByServerId(String serverId);

  @insert
  Future<int> insertHistory(HistoryEntity recent);

  @update
  Future<int> updateHistory(HistoryEntity recent);
}
