import 'package:floor/floor.dart';

import 'package:deup/database/entity/index.dart';

@dao
abstract class PluginDao {
  @Query('SELECT * FROM plugin')
  Future<List<PluginEntity>> findAllPlugin();

  @Query('SELECT * FROM plugin WHERE id = :id')
  Future<PluginEntity?> findPluginById(String id);

  @Query('DELETE FROM plugin WHERE id = :id')
  Future<void> deletePluginById(String id);

  @insert
  Future<int> insertPlugin(PluginEntity plugin);

  @update
  Future<int> updatePlugin(PluginEntity plugin);
}
