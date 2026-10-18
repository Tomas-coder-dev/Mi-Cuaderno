// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paquete.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaqueteAdapter extends TypeAdapter<Paquete> {
  @override
  final int typeId = 0;

  @override
  Paquete read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Paquete(
      id: fields[0] as String,
      numero: fields[1] as String,
      descripcion: fields[2] as String,
      fechaLlegada: fields[3] as DateTime,
      fechaEnvio: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Paquete obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.numero)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.fechaLlegada)
      ..writeByte(4)
      ..write(obj.fechaEnvio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaqueteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
