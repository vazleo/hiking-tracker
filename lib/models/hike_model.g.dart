// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hike_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HikeAdapter extends TypeAdapter<Hike> {
  @override
  final int typeId = 0;

  @override
  Hike read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hike(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      durationInSeconds: fields[3] as int,
      distanceInMeters: fields[4] as double,
      points: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, double>())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, Hike obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.durationInSeconds)
      ..writeByte(4)
      ..write(obj.distanceInMeters)
      ..writeByte(5)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HikeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
