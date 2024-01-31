import 'package:floor/floor.dart';

@Entity(
  tableName: 'plugin',
)
class PluginEntity {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'config')
  final String config;

  @ColumnInfo(name: 'inputs')
  final String inputs;

  @ColumnInfo(name: 'script')
  final String script;

  @ColumnInfo(name: 'link')
  final String? link;

  PluginEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.config,
    required this.inputs,
    required this.script,
    this.link,
  });
}
