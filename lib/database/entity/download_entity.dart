import 'package:floor/floor.dart';

@Entity(
  tableName: 'download',
  indices: [
    Index(value: ['server_id', 'object_id'], unique: true),
    Index(value: ['task_id'], unique: false),
  ],
)
class DownloadEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final String serverId;

  @ColumnInfo(name: 'task_id')
  final String taskId;

  @ColumnInfo(name: 'type')
  final String type;

  @ColumnInfo(name: 'object_id')
  final String objectId;

  @ColumnInfo(name: 'name')
  final String name;

  @ColumnInfo(name: 'size')
  final int size;

  DownloadEntity({
    this.id,
    required this.serverId,
    required this.taskId,
    required this.type,
    required this.objectId,
    required this.name,
    required this.size,
  });
}
