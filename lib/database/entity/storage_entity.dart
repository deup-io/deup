import 'package:floor/floor.dart';

@Entity(
  tableName: 'storage',
  indices: [
    Index(value: ['server_id'], unique: true),
  ],
)
class StorageEntity {
  @PrimaryKey()
  final String id;

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'server_id')
  final String serverId;

  @ColumnInfo(name: 'data')
  final String data;

  StorageEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.serverId,
    required this.data,
  });
}
