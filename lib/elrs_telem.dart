import 'package:elrs_telem/models.dart';
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
        ElrsTelemetry.homeLocation ??= Location(
          latitude: lat / 1e7,
          longitude: lon / 1e7,
          altitude: gpsAltitude.toDouble(),
          heading: gpsHeading / 100,
        );
        ElrsTelemetry.uavLocation!.latitude = lat / 1e7;
        ElrsTelemetry.uavLocation!.longitude = lon / 1e7;
        ElrsTelemetry.uavLocation!.altitude = gpsAltitude.toDouble();
        ElrsTelemetry.uavLocation!.heading = gpsHeading / 100;
        ElrsTelemetry.uavLocation!.groundSpeed = groundSpeed / 10;
        ElrsTelemetry.uavLocation!.gpsSatellites = gpsSatellites;
        break;
      case PacketType.vario: //0x07
        int varioAltitude = packet.payload
            .sublist(0, 2)
            .buffer
            .asByteData()
            .getInt16(0); // / 10, m/s
        ElrsTelemetry.altitude = varioAltitude / 10;
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
        ElrsTelemetry.batterySensor ??= BatterySensor(
          voltage: voltage / 10,
          current: current / 10,
          capacity: capacity,
          percentage: soc,
        );
        ElrsTelemetry.batterySensor!.voltage = voltage / 10;
        ElrsTelemetry.batterySensor!.current = current / 10;
        ElrsTelemetry.batterySensor!.capacity = capacity;
        ElrsTelemetry.batterySensor!.percentage = soc;
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
          ElrsTelemetry.altitude = altitude.toDouble();
        } else {
          //Altitude is in decimeters
          altitude = packet.payload
              .sublist(0, 2)
              .buffer
              .asByteData()
              .getUint16(0); // - 10000, decimeters
          ElrsTelemetry.altitude = (altitude - 10000) / 10;
        }
        int verticalSpeed = packet.payload
            .sublist(2, 4)
            .buffer
            .asByteData()
            .getInt16(0); //, cm/s
        ElrsTelemetry.varioSpeed = verticalSpeed / 100;
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
        ElrsTelemetry.videoTransmitter ??= VideoTransmitter(
          originAddress: originAddress,
          status: status,
          bandChannel: bandChannel,
          userFrequency: userFrequency,
          pitModeAndPower: pitModeAndPower,
        );
        ElrsTelemetry.videoTransmitter!.originAddress = originAddress;
        ElrsTelemetry.videoTransmitter!.status = status;
        ElrsTelemetry.videoTransmitter!.bandChannel = bandChannel;
        ElrsTelemetry.videoTransmitter!.userFrequency = userFrequency;
        ElrsTelemetry.videoTransmitter!.pitModeAndPower = pitModeAndPower;
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

        ElrsTelemetry.linkStatistics ??= LinkStatistics(
          uplinkRssi1: uplinkRssi1,
          uplinkRssi2: uplinkRssi2,
          uplinkLinkQuality: uplinkLinkQuality,
          uplinkSnr: uplinkSnr,
          activeAntenna: activeAntenna,
          rfMode: rfMode,
          uplinkTxPower: uplinkTxPower,
          downlinkRssi: downlinkRssi,
          downlinkLinkQuality: downlinkLinkQuality,
          downlinkSnr: downlinkSnr,
        );
        ElrsTelemetry.linkStatistics!.uplinkRssi1 = uplinkRssi1;
        ElrsTelemetry.linkStatistics!.uplinkRssi2 = uplinkRssi2;
        ElrsTelemetry.linkStatistics!.uplinkLinkQuality = uplinkLinkQuality;
        ElrsTelemetry.linkStatistics!.uplinkSnr = uplinkSnr;
        ElrsTelemetry.linkStatistics!.activeAntenna = activeAntenna;
        ElrsTelemetry.linkStatistics!.rfMode = rfMode;
        ElrsTelemetry.linkStatistics!.uplinkTxPower = uplinkTxPower;
        ElrsTelemetry.linkStatistics!.downlinkRssi = downlinkRssi;
        ElrsTelemetry.linkStatistics!.downlinkLinkQuality = downlinkLinkQuality;
        ElrsTelemetry.linkStatistics!.downlinkSnr = downlinkSnr;
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
        ElrsTelemetry.attitude ??= Attitude(
          roll: roll / 10000,
          pitch: pitch / 10000,
          yaw: yaw / 10000,
        );
        ElrsTelemetry.attitude!.roll = roll / 10000;
        ElrsTelemetry.attitude!.pitch = pitch / 10000;
        ElrsTelemetry.attitude!.yaw = yaw / 10000;
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
        String serialNumber = String.fromCharCodes(
          sublist.sublist(nullIndex + 1, nullIndex + 5),
        );
        int hardwareVersion = sublist
            .sublist(nullIndex + 5, nullIndex + 9)
            .buffer
            .asByteData()
            .getUint32(0);
        String softwareVersion = sublist
            .sublist(nullIndex + 10, nullIndex + 13)
            .map((e) => e.toString())
            .join('.');
        int maxMspParameter = packet.payload[nullIndex + 12];
        int parameterVersion = packet.payload[nullIndex + 13];
        ElrsTelemetry.deviceInfo ??= DeviceInfo(
          destination: destination,
          origin: origin,
          deviceName: deviceName,
          serialNumber: serialNumber,
          hardwareVersion: hardwareVersion,
          softwareVersion: softwareVersion,
          maxMspParameter: maxMspParameter,
          parameterVersion: parameterVersion,
        );
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
        // int radioAddress = packet.payload
        //     .sublist(0, 2)
        //     .buffer
        //     .asByteData()
        //     .getUint16(0);
        // int timingCorrectionFrame = packet.payload[2];
        // int updateInterval = packet.payload
        //     .sublist(3, 7)
        //     .buffer
        //     .asByteData()
        //     .getUint32(0);
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
