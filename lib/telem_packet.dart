import 'dart:typed_data';

import 'package:elrs_telem/enums.dart';

class TelemetryPacket {
  static const int _prefixSize = 8;

  //Unknown
  Uint8List prefix;

  CrsfAddress syncByte;

  //Includes the length of the packetType, payload, and crc
  int length;

  PacketType packetType;

  Uint8List payload;

  //CRC8 using poly 0xD5, includes all bytes from type (buffer[2]) to end of payload.
  int crc;

  bool isValidCrc;

  TelemetryPacket({
    required this.prefix,
    required this.syncByte,
    required this.length,
    required this.packetType,
    required this.payload,
    required this.crc,
    this.isValidCrc = false,
  });

  factory TelemetryPacket.fromBytes(Uint8List bytes) {
    if (bytes.length < _prefixSize) {
      throw Exception('Invalid packet size: ${bytes.length}');
    }

    Uint8List suffix = bytes.sublist(_prefixSize, bytes.length - 1);

    final syncByte = CrsfAddress.fromValue(suffix[0]);
    final length = suffix[1];
    final packetType = PacketType.fromValue(suffix[2]);
    final payload = suffix.sublist(3, suffix.length - 1);
    final crc = suffix[suffix.length - 1];

    final dataToCheck = Uint8List.fromList([packetType.value, ...payload]);

    return TelemetryPacket(
      prefix: bytes.sublist(0, _prefixSize),
      syncByte: syncByte,
      length: length,
      packetType: packetType,
      payload: payload,
      crc: crc,
      isValidCrc: calculateCrc(dataToCheck) == crc,
    );
  }

  static int calculateCrc(Uint8List data) {
    const int polynomial = 0xD5;
    int crc = 0;

    for (final byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x80) != 0) {
          crc = (crc << 1) ^ polynomial;
        } else {
          crc <<= 1;
        }
        crc &= 0xFF; // Ensure CRC remains 8-bit
      }
    }

    return crc;
  }
}
