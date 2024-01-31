// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorDeupDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$DeupDatabaseBuilder databaseBuilder(String name) =>
      _$DeupDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$DeupDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$DeupDatabaseBuilder(null);
}

class _$DeupDatabaseBuilder {
  _$DeupDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$DeupDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$DeupDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<DeupDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$DeupDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$DeupDatabase extends DeupDatabase {
  _$DeupDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PluginDao? _pluginDaoInstance;

  ServerDao? _serverDaoInstance;

  HistoryDao? _historyDaoInstance;

  StorageDao? _storageDaoInstance;

  DownloadDao? _downloadDaoInstance;

  ProgressDao? _progressDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `plugin` (`id` TEXT NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `config` TEXT NOT NULL, `inputs` TEXT NOT NULL, `script` TEXT NOT NULL, `link` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `server` (`id` TEXT NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `name` TEXT NOT NULL, `plugin_id` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `history` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` TEXT NOT NULL, `updated_at` INTEGER NOT NULL, `object_id` TEXT NOT NULL, `data` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `storage` (`id` TEXT NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `server_id` TEXT NOT NULL, `data` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `download` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` TEXT NOT NULL, `task_id` TEXT NOT NULL, `type` TEXT NOT NULL, `object_id` TEXT NOT NULL, `name` TEXT NOT NULL, `size` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `progress` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `server_id` TEXT NOT NULL, `object_id` TEXT NOT NULL, `current_pos` INTEGER NOT NULL, `duration` INTEGER NOT NULL)');
        await database.execute(
            'CREATE INDEX `index_server_plugin_id` ON `server` (`plugin_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_history_server_id_object_id` ON `history` (`server_id`, `object_id`)');
        await database.execute(
            'CREATE INDEX `index_history_updated_at` ON `history` (`updated_at`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_storage_server_id` ON `storage` (`server_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_download_server_id_object_id` ON `download` (`server_id`, `object_id`)');
        await database.execute(
            'CREATE INDEX `index_download_task_id` ON `download` (`task_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_progress_server_id_object_id` ON `progress` (`server_id`, `object_id`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PluginDao get pluginDao {
    return _pluginDaoInstance ??= _$PluginDao(database, changeListener);
  }

  @override
  ServerDao get serverDao {
    return _serverDaoInstance ??= _$ServerDao(database, changeListener);
  }

  @override
  HistoryDao get historyDao {
    return _historyDaoInstance ??= _$HistoryDao(database, changeListener);
  }

  @override
  StorageDao get storageDao {
    return _storageDaoInstance ??= _$StorageDao(database, changeListener);
  }

  @override
  DownloadDao get downloadDao {
    return _downloadDaoInstance ??= _$DownloadDao(database, changeListener);
  }

  @override
  ProgressDao get progressDao {
    return _progressDaoInstance ??= _$ProgressDao(database, changeListener);
  }
}

class _$PluginDao extends PluginDao {
  _$PluginDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _pluginEntityInsertionAdapter = InsertionAdapter(
            database,
            'plugin',
            (PluginEntity item) => <String, Object?>{
                  'id': item.id,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'config': item.config,
                  'inputs': item.inputs,
                  'script': item.script,
                  'link': item.link
                }),
        _pluginEntityUpdateAdapter = UpdateAdapter(
            database,
            'plugin',
            ['id'],
            (PluginEntity item) => <String, Object?>{
                  'id': item.id,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'config': item.config,
                  'inputs': item.inputs,
                  'script': item.script,
                  'link': item.link
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PluginEntity> _pluginEntityInsertionAdapter;

  final UpdateAdapter<PluginEntity> _pluginEntityUpdateAdapter;

  @override
  Future<List<PluginEntity>> findAllPlugin() async {
    return _queryAdapter.queryList('SELECT * FROM plugin',
        mapper: (Map<String, Object?> row) => PluginEntity(
            id: row['id'] as String,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            config: row['config'] as String,
            inputs: row['inputs'] as String,
            script: row['script'] as String,
            link: row['link'] as String?));
  }

  @override
  Future<PluginEntity?> findPluginById(String id) async {
    return _queryAdapter.query('SELECT * FROM plugin WHERE id = ?1',
        mapper: (Map<String, Object?> row) => PluginEntity(
            id: row['id'] as String,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            config: row['config'] as String,
            inputs: row['inputs'] as String,
            script: row['script'] as String,
            link: row['link'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> deletePluginById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM plugin WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int> insertPlugin(PluginEntity plugin) {
    return _pluginEntityInsertionAdapter.insertAndReturnId(
        plugin, OnConflictStrategy.abort);
  }

  @override
  Future<int> updatePlugin(PluginEntity plugin) {
    return _pluginEntityUpdateAdapter.updateAndReturnChangedRows(
        plugin, OnConflictStrategy.abort);
  }
}

class _$ServerDao extends ServerDao {
  _$ServerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _serverEntityInsertionAdapter = InsertionAdapter(
            database,
            'server',
            (ServerEntity item) => <String, Object?>{
                  'id': item.id,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'name': item.name,
                  'plugin_id': item.pluginId
                }),
        _serverEntityUpdateAdapter = UpdateAdapter(
            database,
            'server',
            ['id'],
            (ServerEntity item) => <String, Object?>{
                  'id': item.id,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'name': item.name,
                  'plugin_id': item.pluginId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ServerEntity> _serverEntityInsertionAdapter;

  final UpdateAdapter<ServerEntity> _serverEntityUpdateAdapter;

  @override
  Future<List<ServerEntity>> findServerByPluginId(String pluginId) async {
    return _queryAdapter.queryList('SELECT * FROM server WHERE plugin_id = ?1',
        mapper: (Map<String, Object?> row) => ServerEntity(
            id: row['id'] as String,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            name: row['name'] as String,
            pluginId: row['plugin_id'] as String),
        arguments: [pluginId]);
  }

  @override
  Future<ServerEntity?> findServerById(String id) async {
    return _queryAdapter.query('SELECT * FROM server WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ServerEntity(
            id: row['id'] as String,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            name: row['name'] as String,
            pluginId: row['plugin_id'] as String),
        arguments: [id]);
  }

  @override
  Future<void> deleteServerById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM server WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<int> insertServer(ServerEntity server) {
    return _serverEntityInsertionAdapter.insertAndReturnId(
        server, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateServer(ServerEntity server) {
    return _serverEntityUpdateAdapter.updateAndReturnChangedRows(
        server, OnConflictStrategy.abort);
  }
}

class _$HistoryDao extends HistoryDao {
  _$HistoryDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _historyEntityInsertionAdapter = InsertionAdapter(
            database,
            'history',
            (HistoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'updated_at': item.updatedAt,
                  'object_id': item.objectId,
                  'data': item.data
                }),
        _historyEntityUpdateAdapter = UpdateAdapter(
            database,
            'history',
            ['id'],
            (HistoryEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'updated_at': item.updatedAt,
                  'object_id': item.objectId,
                  'data': item.data
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<HistoryEntity> _historyEntityInsertionAdapter;

  final UpdateAdapter<HistoryEntity> _historyEntityUpdateAdapter;

  @override
  Future<List<HistoryEntity>> findHistoryByServerId(
    String serverId,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM history WHERE server_id = ?1 ORDER BY updated_at DESC LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => HistoryEntity(id: row['id'] as int?, serverId: row['server_id'] as String, updatedAt: row['updated_at'] as int, objectId: row['object_id'] as String, data: row['data'] as String),
        arguments: [serverId, limit, offset]);
  }

  @override
  Future<HistoryEntity?> findHistoryByServerIdAndObjectId(
    String serverId,
    String objectId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM history WHERE server_id = ?1 AND object_id = ?2',
        mapper: (Map<String, Object?> row) => HistoryEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as String,
            updatedAt: row['updated_at'] as int,
            objectId: row['object_id'] as String,
            data: row['data'] as String),
        arguments: [serverId, objectId]);
  }

  @override
  Future<void> deleteHistoryById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM history WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteHistoryByServerId(String serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM history WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertHistory(HistoryEntity recent) {
    return _historyEntityInsertionAdapter.insertAndReturnId(
        recent, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateHistory(HistoryEntity recent) {
    return _historyEntityUpdateAdapter.updateAndReturnChangedRows(
        recent, OnConflictStrategy.abort);
  }
}

class _$StorageDao extends StorageDao {
  _$StorageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _storageEntityInsertionAdapter = InsertionAdapter(
            database,
            'storage',
            (StorageEntity item) => <String, Object?>{
                  'id': item.id,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'server_id': item.serverId,
                  'data': item.data
                }),
        _storageEntityUpdateAdapter = UpdateAdapter(
            database,
            'storage',
            ['id'],
            (StorageEntity item) => <String, Object?>{
                  'id': item.id,
                  'created_at': item.createdAt,
                  'updated_at': item.updatedAt,
                  'server_id': item.serverId,
                  'data': item.data
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StorageEntity> _storageEntityInsertionAdapter;

  final UpdateAdapter<StorageEntity> _storageEntityUpdateAdapter;

  @override
  Future<StorageEntity?> findStorageByServerId(String serverId) async {
    return _queryAdapter.query('SELECT * FROM storage WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => StorageEntity(
            id: row['id'] as String,
            createdAt: row['created_at'] as int,
            updatedAt: row['updated_at'] as int,
            serverId: row['server_id'] as String,
            data: row['data'] as String),
        arguments: [serverId]);
  }

  @override
  Future<void> deleteStorageByServerId(String serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM storage WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertStorage(StorageEntity storage) {
    return _storageEntityInsertionAdapter.insertAndReturnId(
        storage, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateStorage(StorageEntity storage) {
    return _storageEntityUpdateAdapter.updateAndReturnChangedRows(
        storage, OnConflictStrategy.abort);
  }
}

class _$DownloadDao extends DownloadDao {
  _$DownloadDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _downloadEntityInsertionAdapter = InsertionAdapter(
            database,
            'download',
            (DownloadEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'task_id': item.taskId,
                  'type': item.type,
                  'object_id': item.objectId,
                  'name': item.name,
                  'size': item.size
                }),
        _downloadEntityUpdateAdapter = UpdateAdapter(
            database,
            'download',
            ['id'],
            (DownloadEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'task_id': item.taskId,
                  'type': item.type,
                  'object_id': item.objectId,
                  'name': item.name,
                  'size': item.size
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DownloadEntity> _downloadEntityInsertionAdapter;

  final UpdateAdapter<DownloadEntity> _downloadEntityUpdateAdapter;

  @override
  Future<List<DownloadEntity>> findAllDownload() async {
    return _queryAdapter.queryList('SELECT * FROM download',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as String,
            taskId: row['task_id'] as String,
            type: row['type'] as String,
            objectId: row['object_id'] as String,
            name: row['name'] as String,
            size: row['size'] as int));
  }

  @override
  Future<DownloadEntity?> findDownloadById(int id) async {
    return _queryAdapter.query('SELECT * FROM download WHERE id = ?1',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as String,
            taskId: row['task_id'] as String,
            type: row['type'] as String,
            objectId: row['object_id'] as String,
            name: row['name'] as String,
            size: row['size'] as int),
        arguments: [id]);
  }

  @override
  Future<DownloadEntity?> findDownloadByServerId(String serverId) async {
    return _queryAdapter.query('SELECT * FROM download WHERE server_id = ?1',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as String,
            taskId: row['task_id'] as String,
            type: row['type'] as String,
            objectId: row['object_id'] as String,
            name: row['name'] as String,
            size: row['size'] as int),
        arguments: [serverId]);
  }

  @override
  Future<DownloadEntity?> findDownloadByServerIdAndObjectId(
    String serverId,
    String objectId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM download WHERE server_id = ?1 AND object_id = ?2',
        mapper: (Map<String, Object?> row) => DownloadEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as String,
            taskId: row['task_id'] as String,
            type: row['type'] as String,
            objectId: row['object_id'] as String,
            name: row['name'] as String,
            size: row['size'] as int),
        arguments: [serverId, objectId]);
  }

  @override
  Future<void> deleteDownloadById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM download WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteDownloadByServerId(String serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM download WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertDownload(DownloadEntity download) {
    return _downloadEntityInsertionAdapter.insertAndReturnId(
        download, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateDownload(DownloadEntity download) {
    return _downloadEntityUpdateAdapter.updateAndReturnChangedRows(
        download, OnConflictStrategy.abort);
  }
}

class _$ProgressDao extends ProgressDao {
  _$ProgressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _progressEntityInsertionAdapter = InsertionAdapter(
            database,
            'progress',
            (ProgressEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'object_id': item.objectId,
                  'current_pos': item.currentPos,
                  'duration': item.duration
                }),
        _progressEntityUpdateAdapter = UpdateAdapter(
            database,
            'progress',
            ['id'],
            (ProgressEntity item) => <String, Object?>{
                  'id': item.id,
                  'server_id': item.serverId,
                  'object_id': item.objectId,
                  'current_pos': item.currentPos,
                  'duration': item.duration
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProgressEntity> _progressEntityInsertionAdapter;

  final UpdateAdapter<ProgressEntity> _progressEntityUpdateAdapter;

  @override
  Future<ProgressEntity?> findProgressByServerIdAndObjectId(
    String serverId,
    String objectId,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM progress WHERE server_id = ?1 AND object_id = ?2',
        mapper: (Map<String, Object?> row) => ProgressEntity(
            id: row['id'] as int?,
            serverId: row['server_id'] as String,
            objectId: row['object_id'] as String,
            currentPos: row['current_pos'] as int,
            duration: row['duration'] as int),
        arguments: [serverId, objectId]);
  }

  @override
  Future<void> deleteProgressById(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM progress WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteProgressByServerId(String serverId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM progress WHERE server_id = ?1',
        arguments: [serverId]);
  }

  @override
  Future<int> insertProgress(ProgressEntity progress) {
    return _progressEntityInsertionAdapter.insertAndReturnId(
        progress, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateProgress(ProgressEntity progress) {
    return _progressEntityUpdateAdapter.updateAndReturnChangedRows(
        progress, OnConflictStrategy.abort);
  }
}
