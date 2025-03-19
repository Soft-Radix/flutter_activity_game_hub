// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaderboardEntryAdapter extends TypeAdapter<LeaderboardEntry> {
  @override
  final int typeId = 1;

  @override
  LeaderboardEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaderboardEntry(
      id: fields[0] as String,
      playerOrTeamName: fields[1] as String,
      gameId: fields[2] as String,
      gameName: fields[3] as String,
      score: fields[4] as int,
      datePlayed: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LeaderboardEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.playerOrTeamName)
      ..writeByte(2)
      ..write(obj.gameId)
      ..writeByte(3)
      ..write(obj.gameName)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.datePlayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaderboardEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
