part of 'viaje.dart';

class ViajeAdapter extends TypeAdapter<Viaje> {
  @override
  final int typeId = 1;

  @override
  Viaje read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Viaje(
      id: fields[0] as String,
      fecha: fields[1] as DateTime,
      nota: fields[2] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Viaje obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fecha)
      ..writeByte(2)
      ..write(obj.nota);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViajeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
