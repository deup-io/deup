import 'package:floor/floor.dart';

@Entity(
  tableName: 'progress',
  indices: [
    Index(value: ['server_id', 'object_id'], unique: true),
  ],
)
class ProgressEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  final String serverId;

  @ColumnInfo(name: 'object_id')
  final String objectId;

  @ColumnInfo(name: 'current_pos')
  final int currentPos;

  @ColumnInfo(name: 'duration')
  final int duration;

  ProgressEntity({
    this.id,
    required this.serverId,
    required this.objectId,
    required this.currentPos,
    required this.duration,
  });
}
