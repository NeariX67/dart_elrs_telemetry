import 'package:elrs_telem/telem_packet.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

class ElrsTelem {
  TelemetryPacket? parsePacket(Uint8List payload) {
    TelemetryPacket packet = TelemetryPacket.fromBytes(payload);
    if (!packet.isValidCrc) {
      debugPrint('Invalid CRC for packet type: ${packet.packetType}');
      return null;
    }
    return packet;
  }

  void processPacket(TelemetryPacket packet) {
    switch (packet.packetType) {
      case PacketType.gps: //0x02
        int lat = packet.payload
            .sublist(0, 4)
            .buffer
            .asByteData()
            .getInt32(0); // / 1e7;
        int lon = packet.payload
            .sublist(4, 8)
            .buffer
            .asByteData()
            .getInt32(0); // / 1e7;
        int groundSpeed = packet.payload
            .sublist(8, 10)
            .buffer
            .asByteData()
            .getInt16(0); // / 10, km/h
        int gpsHeading = packet.payload
            .sublist(10, 12)
            .buffer
            .asByteData()
            .getInt16(0); // / 100, degrees
        int gpsAltitude =
            packet.payload.sublist(12, 14).buffer.asByteData().getUint16(0) -
            1000; // offset 1000, meters
        int gpsSatellites = packet.payload[14];
        break;
      case PacketType.vario: //0x07
        int varioAltitude = packet.payload
            .sublist(0, 2)
            .buffer
            .asByteData()
            .getInt16(0); // / 10, m/s
        break;
      case PacketType.batterySensor: //0x08
        int voltage = packet.payload
            .sublist(0, 2)
            .buffer
            .asByteData()
            .getInt16(0); // / 10, V
        int current = packet.payload
            .sublist(2, 4)
            .buffer
            .asByteData()
            .getInt16(0); // / 10, A
        int capacity = packet.payload
            .sublist(4, 7)
            .buffer
            .asByteData()
            .getInt32(0); // mAh
        int soc = packet.payload[7]; // 0-100, %
        break;
      case PacketType.baroAltitude: //0x09
        int altitude;
        int highBit = packet.payload[0];
        if (highBit & 0x80 == 0x80) {
          //Altitude is in meters
          altitude = packet.payload
              .sublist(0, 2)
              .buffer
              .asByteData()
              .getUint16(0); // meters
        } else {
          //Altitude is in decimeters
          altitude = packet.payload
              .sublist(0, 2)
              .buffer
              .asByteData()
              .getUint16(0); // - 10000, decimeters
        }
        int verticalSpeed = packet.payload
            .sublist(2, 4)
            .buffer
            .asByteData()
            .getInt16(0); //, cm/s
        break;
      case PacketType.heartbeat: //0x0B
        int originDeviceAddress = packet.payload[0];
        break;
      case PacketType.videoTransmitter: //0x0F
        int originAddress = packet.payload[0];
        int status = packet.payload[1];
        int bandChannel = packet.payload[2];
        int userFrequency = packet.payload
            .sublist(3, 5)
            .buffer
            .asByteData()
            .getUint16(0);
        int pitModeAndPower = packet.payload[5];
      case PacketType.opentxSync: //0x10
      case PacketType.linkStatistics: //0x14
        int uplinkRssi1 = packet.payload[0];
        int uplinkRssi2 = packet.payload[1];
        int uplinkLinkQuality = packet.payload[2];
        int uplinkSnr = packet.payload[3];
        int activeAntenna = packet.payload[4];
        int rfMode = packet.payload[5];
        int uplinkTxPower = packet.payload[6];
        int downlinkRssi = packet.payload[7];
        int downlinkLinkQuality = packet.payload[8];
        int downlinkSnr = packet.payload[9];
        break;
      case PacketType.rcChannelsPacked: //0x16
        break;
      case PacketType.subsetRcChannelsPacked: //0x17
        break;
      case PacketType.linkRxId: //0x1C
        break;
      case PacketType.linkTxId: //0x1D
        break;
      case PacketType.attitude: //0x1E
        int pitch = packet.payload
            .sublist(0, 2)
            .buffer
            .asByteData()
            .getInt16(0); // / 10000, degrees
        int roll = packet.payload
            .sublist(2, 4)
            .buffer
            .asByteData()
            .getInt16(0); // / 10000, degrees
        int yaw = packet.payload
            .sublist(4, 6)
            .buffer
            .asByteData()
            .getInt16(0); // / 10000, degrees
        break;
      case PacketType.flightMode: //0x21
        break;
      case PacketType.devicePing: //0x28
        break;
      case PacketType.deviceInfo: //0x29
        int destination = packet.payload[0];
        int origin = packet.payload[1];
        Uint8List sublist = packet.payload.sublist(2);
        int nullIndex = sublist.indexOf(0);
        if (nullIndex == -1) {
          break;
        }

        String deviceName = String.fromCharCodes(sublist.sublist(0, nullIndex));
        // 4 bytes empty
        // 4 bytes empty
        // 4 bytes empty
        int maxMspParameter = packet.payload[nullIndex + 12];
        int parameterVersion = packet.payload[nullIndex + 13];
        break;
      case PacketType.parameterSettingsEntry: //0x2B
        break;
      case PacketType.parameterRead: //0x2C
        break;
      case PacketType.parameterWrite: //0x2D
        break;
      case PacketType.elrsStatus: //0x2E
        break;
      case PacketType.command: //0x32
        break;
      case PacketType.radioId: //RADIO 0x3A
        int radioAddress = packet.payload
            .sublist(0, 2)
            .buffer
            .asByteData()
            .getUint16(0);
        int timingCorrectionFrame = packet.payload[2];
        int updateInterval = packet.payload
            .sublist(3, 7)
            .buffer
            .asByteData()
            .getUint32(0);
        // int32
        break;
      case PacketType.kissReq: //KISS 0x78
        break;
      case PacketType.kissResp: //KISS 0x79
        break;
      case PacketType.mspReq: //MSP 0x7A
        break;
      case PacketType.mspResp: //MSP 0x7B
        break;
      case PacketType.mspWrite: //MSP 0x7C
        break;
      case PacketType.displayportCm: //DISPLAYPORT 0x7D
        break;
      case PacketType.ardupilotResp: //ARDUPILOT 0x80
        break;
      default:
        debugPrint('Unhandled packet type: ${packet.packetType}');
    }
  }
}
