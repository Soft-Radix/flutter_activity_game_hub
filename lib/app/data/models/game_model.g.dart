// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameAdapter extends TypeAdapter<Game> {
  @override
  final int typeId = 0;

  @override
  Game read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Game(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      imageUrl: fields[4] as String,
      minPlayers: fields[5] as int,
      maxPlayers: fields[6] as int,
      estimatedTimeMinutes: fields[7] as int,
      instructions: (fields[8] as List).cast<String>(),
      isFeatured: fields[9] as bool,
      difficultyLevel: fields[10] as String,
      materialsRequired: (fields[11] as List).cast<String>(),
      gameType: fields[12] as String,
      rating: fields[13] as double,
      isTimeBound: fields[14] as bool,
      teamBased: fields[15] as bool,
      rules: (fields[16] as List).cast<String>(),
      howToPlay: fields[17] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Game obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.minPlayers)
      ..writeByte(6)
      ..write(obj.maxPlayers)
      ..writeByte(7)
      ..write(obj.estimatedTimeMinutes)
      ..writeByte(8)
      ..write(obj.instructions)
      ..writeByte(9)
      ..write(obj.isFeatured)
      ..writeByte(10)
      ..write(obj.difficultyLevel)
      ..writeByte(11)
      ..write(obj.materialsRequired)
      ..writeByte(12)
      ..write(obj.gameType)
      ..writeByte(13)
      ..write(obj.rating)
      ..writeByte(14)
      ..write(obj.isTimeBound)
      ..writeByte(15)
      ..write(obj.teamBased)
      ..writeByte(16)
      ..write(obj.rules)
      ..writeByte(17)
      ..write(obj.howToPlay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
