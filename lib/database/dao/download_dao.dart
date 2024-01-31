import 'package:floor/floor.dart';

import 'package:deup/database/entity/index.dart';

@dao
abstract class DownloadDao {
  @Query('SELECT * FROM download')
  Future<List<DownloadEntity>> findAllDownload();

  @Query('SELECT * FROM download WHERE id = :id')
  Future<DownloadEntity?> findDownloadById(int id);

  @Query('SELECT * FROM download WHERE server_id = :serverId')
  Future<DownloadEntity?> findDownloadByServerId(String serverId);

  @Query(
    'SELECT * FROM download WHERE server_id = :serverId AND object_id = :objectId',
  )
  Future<DownloadEntity?> findDownloadByServerIdAndObjectId(
      String serverId, String objectId);

  @Query('DELETE FROM download WHERE id = :id')
  Future<void> deleteDownloadById(int id);

  @Query('DELETE FROM download WHERE server_id = :serverId')
  Future<void> deleteDownloadByServerId(String serverId);

  @insert
  Future<int> insertDownload(DownloadEntity download);

  @update
  Future<int> updateDownload(DownloadEntity download);
}
