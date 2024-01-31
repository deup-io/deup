import 'package:floor/floor.dart';

@Entity(
  tableName: 'server',
  indices: [
    Index(value: ['plugin_id'], unique: false),
  ],
)
class ServerEntity {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'plugin_id')
  final String pluginId;

  ServerEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.pluginId,
  });
}
