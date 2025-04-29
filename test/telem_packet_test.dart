import 'dart:typed_data';

import 'package:elrs_telem/enums.dart';
import 'package:elrs_telem/telem_packet.dart';
import 'package:flutter_test/flutter_test.dart';

import 'packets.dart';

void main() {
  test('Parse linkStatistics', () {
    final TelemetryPacket packet = TelemetryPacket.fromBytes(
      TelemPackets.linkStatistics,
    );
    expect(
      packet.prefix,
      Uint8List.fromList([0x24, 0x58, 0x3C, 0x00, 0x11, 0x00, 0x0E, 0x00]),
    );
    expect(packet.syncByte, CrsfAddress.radioTransmitter);
    expect(packet.length, 12);
    expect(packet.length, packet.payload.length + 2);
    expect(packet.packetType, PacketType.linkStatistics);
    expect(
      packet.payload,
      Uint8List.fromList([
        0xD6,
        0xD5,
        0x64,
        0x0D,
        0x01,
        0x05,
        0x02,
        0xDA,
        0x64,
        0x0D,
      ]),
    );
    expect(packet.crc, 0xDF);
    expect(packet.isValidCrc, true);
  });

  test('Parse batterySensor', () {
    final TelemetryPacket packet = TelemetryPacket.fromBytes(
      TelemPackets.batterySensor,
    );
    expect(
      packet.prefix,
      Uint8List.fromList([0x24, 0x58, 0x3C, 0x00, 0x11, 0x00, 0x0C, 0x00]),
    );
    expect(packet.syncByte, CrsfAddress.radioTransmitter);
    expect(packet.length, 10);
    expect(packet.length, packet.payload.length + 2);
    expect(packet.packetType, PacketType.batterySensor);
    expect(
      packet.payload,
      Uint8List.fromList([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
    );
    expect(packet.crc, 0x6D);
    expect(packet.isValidCrc, true);
  });
  test('Parse attitude', () {
    final TelemetryPacket packet = TelemetryPacket.fromBytes(
      TelemPackets.attitude,
    );
    expect(
      packet.prefix,
      Uint8List.fromList([0x24, 0x58, 0x3C, 0x00, 0x11, 0x00, 0x0A, 0x00]),
    );
    expect(packet.syncByte, CrsfAddress.radioTransmitter);
    expect(packet.length, 8);
    expect(packet.length, packet.payload.length + 2);
    expect(packet.packetType, PacketType.attitude);
    expect(
      packet.payload,
      Uint8List.fromList([0xFA, 0xF5, 0xFF, 0x75, 0xF8, 0x81]),
    );
    expect(packet.crc, 0xA5);
    expect(packet.isValidCrc, true);
  });
  test('Parse flightMode', () {
    final TelemetryPacket packet = TelemetryPacket.fromBytes(
      TelemPackets.flightMode,
    );
    expect(
      packet.prefix,
      Uint8List.fromList([0x24, 0x58, 0x3C, 0x00, 0x11, 0x00, 0x0A, 0x00]),
    );
    expect(packet.syncByte, CrsfAddress.radioTransmitter);
    expect(packet.length, 8);
    expect(packet.length, packet.payload.length + 2);
    expect(packet.packetType, PacketType.flightMode);
    expect(
      packet.payload,
      Uint8List.fromList([0x57, 0x41, 0x49, 0x54, 0x2A, 0x00]),
    );
    expect(packet.crc, 0xB2);
    expect(packet.isValidCrc, true);
  });
}
