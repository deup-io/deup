import 'package:floor/floor.dart';

import 'package:deup/database/entity/index.dart';

@dao
abstract class ServerDao {
  @Query('SELECT * FROM server WHERE plugin_id = :pluginId')
  Future<List<ServerEntity>> findServerByPluginId(String pluginId);

  @Query('SELECT * FROM server WHERE id = :id')
  Future<ServerEntity?> findServerById(String id);

  @Query('DELETE FROM server WHERE id = :id')
  Future<void> deleteServerById(String id);

  @insert
  Future<int> insertServer(ServerEntity server);

  @update
  Future<int> updateServer(ServerEntity server);
}
