import 'package:floor/floor.dart';

@Entity(
  tableName: 'history',
  indices: [
    Index(value: ['server_id', 'object_id'], unique: true),
    Index(value: ['updated_at']),
  ],
)
class HistoryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final String serverId;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'object_id')
  final String objectId;

  @ColumnInfo(name: 'data')
  final String data;

  HistoryEntity({
    this.id,
    required this.serverId,
    required this.updatedAt,
    required this.objectId,
    required this.data,
  });
}
