import 'package:elrs_telem/models.dart';
import 'package:elrs_telem/telem_packet.dart';
import 'package:flutter/foundation.dart';

import 'enums.dart';

class ElrsTelem {
  static TelemetryPacket? parsePacket(Uint8List payload) {
    TelemetryPacket packet = TelemetryPacket.fromBytes(payload);
    if (!packet.isValidCrc) {
      debugPrint('Invalid CRC for packet type: ${packet.packetType}');
      return null;
    }
    return packet;
  }

  static void processPacket(TelemetryPacket packet, ElrsTelemetry telemetry) {
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
        if (telemetry.uavLocation == null) {
          telemetry.uavLocation = UavLocation(
            latitude: lat / 1e7,
            longitude: lon / 1e7,
            altitude: gpsAltitude.toDouble(),
            heading: gpsHeading / 100,
            groundSpeed: groundSpeed / 10,
            gpsSatellites: gpsSatellites,
          );
          telemetry.update();
        }
        telemetry.uavLocation!.latitude = lat / 1e7;
        telemetry.uavLocation!.longitude = lon / 1e7;
        telemetry.uavLocation!.altitude = gpsAltitude.toDouble();
        telemetry.uavLocation!.heading = gpsHeading / 100;
        telemetry.uavLocation!.groundSpeed = groundSpeed / 10;
        telemetry.uavLocation!.gpsSatellites = gpsSatellites;
        telemetry.uavLocation!.update();
        break;
      case PacketType.vario: //0x07
        int varioAltitude = packet.payload
            .sublist(0, 2)
            .buffer
            .asByteData()
            .getInt16(0); // / 10, m/s
        if (telemetry.altitudeVario == null) {
          telemetry.altitudeVario = AltitudeVario(
            altitude: varioAltitude / 10,
            varioSpeed: 0,
          );
          telemetry.update();
        }
        telemetry.altitudeVario!.altitude = varioAltitude / 10;
        telemetry.altitudeVario!.update();
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
            .sublist(4, 6)
            .buffer
            .asByteData()
            .getInt16(0); // mAh
        int soc = packet.payload[7]; // 0-100, %
        if (telemetry.batterySensor == null) {
          telemetry.batterySensor = BatterySensor(
            voltage: voltage / 10,
            current: current / 10,
            capacity: capacity,
            percentage: soc,
          );
          telemetry.update();
        }
        telemetry.batterySensor!.voltage = voltage / 10;
        telemetry.batterySensor!.current = current / 10;
        telemetry.batterySensor!.capacity = capacity;
        telemetry.batterySensor!.percentage = soc;
        telemetry.batterySensor!.update();
        break;
      case PacketType.baroAltitude: //0x09
        int altitude;
        int highBit = packet.payload[0];
        if (telemetry.altitudeVario == null) {
          telemetry.altitudeVario = AltitudeVario(altitude: 0, varioSpeed: 0);
          telemetry.update();
        }
        if (highBit & 0x80 == 0x80) {
          //Altitude is in meters
          altitude = packet.payload
              .sublist(0, 2)
              .buffer
              .asByteData()
              .getUint16(0); // meters
          telemetry.altitudeVario!.altitude = altitude.toDouble();
        } else {
          //Altitude is in decimeters
          altitude = packet.payload
              .sublist(0, 2)
              .buffer
              .asByteData()
              .getUint16(0); // - 10000, decimeters
          telemetry.altitudeVario!.altitude = (altitude - 10000) / 10;
        }
        int verticalSpeed = packet.payload
            .sublist(2, 4)
            .buffer
            .asByteData()
            .getInt16(0); //, cm/s
        telemetry.altitudeVario!.varioSpeed = verticalSpeed / 100;
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
        if (telemetry.videoTransmitter == null) {
          telemetry.videoTransmitter = VideoTransmitter(
            originAddress: originAddress,
            status: status,
            bandChannel: bandChannel,
            userFrequency: userFrequency,
            pitModeAndPower: pitModeAndPower,
          );
          telemetry.update();
        }
        telemetry.videoTransmitter!.originAddress = originAddress;
        telemetry.videoTransmitter!.status = status;
        telemetry.videoTransmitter!.bandChannel = bandChannel;
        telemetry.videoTransmitter!.userFrequency = userFrequency;
        telemetry.videoTransmitter!.pitModeAndPower = pitModeAndPower;
        telemetry.videoTransmitter!.update();
      case PacketType.opentxSync: //0x10
        break;
      case PacketType.linkStatistics: //0x14
        int uplinkRssi1 = -(255 - packet.payload[0]);
        int uplinkRssi2 = -(255 - packet.payload[1]);
        int uplinkLinkQuality = packet.payload[2];
        int uplinkSnr = convertUint8ToInt8(packet.payload[3]);
        int activeAntenna = packet.payload[4] + 1;
        int rfMode = convertRfMode(packet.payload[5]);
        int uplinkTxPower = convertRfPower(packet.payload[6]);
        int downlinkRssi = -(255 - packet.payload[7]);
        int downlinkLinkQuality = packet.payload[8];
        int downlinkSnr = convertUint8ToInt8(packet.payload[9]);

        if (telemetry.linkStatistics == null) {
          telemetry.linkStatistics = LinkStatistics(
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
          telemetry.update();
        }
        telemetry.linkStatistics!.uplinkRssi1 = uplinkRssi1;
        telemetry.linkStatistics!.uplinkRssi2 = uplinkRssi2;
        telemetry.linkStatistics!.uplinkLinkQuality = uplinkLinkQuality;
        telemetry.linkStatistics!.uplinkSnr = uplinkSnr;
        telemetry.linkStatistics!.activeAntenna = activeAntenna;
        telemetry.linkStatistics!.rfMode = rfMode;
        telemetry.linkStatistics!.uplinkTxPower = uplinkTxPower;
        telemetry.linkStatistics!.downlinkRssi = downlinkRssi;
        telemetry.linkStatistics!.downlinkLinkQuality = downlinkLinkQuality;
        telemetry.linkStatistics!.downlinkSnr = downlinkSnr;
        telemetry.linkStatistics!.update();
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
        if (telemetry.attitude == null) {
          telemetry.attitude = Attitude(
            roll: roll / 10000,
            pitch: pitch / 10000,
            yaw: yaw / 10000,
          );
          telemetry.update();
        }
        telemetry.attitude!.roll = roll / 10000;
        telemetry.attitude!.pitch = pitch / 10000;
        telemetry.attitude!.yaw = yaw / 10000;
        telemetry.attitude!.update();
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
        if (telemetry.deviceInfo == null) {
          telemetry.deviceInfo = DeviceInfo(
            destination: destination,
            origin: origin,
            deviceName: deviceName,
            serialNumber: serialNumber,
            hardwareVersion: hardwareVersion,
            softwareVersion: softwareVersion,
            maxMspParameter: maxMspParameter,
            parameterVersion: parameterVersion,
          );
          telemetry.update();
        }
        telemetry.deviceInfo!.destination = destination;
        telemetry.deviceInfo!.origin = origin;
        telemetry.deviceInfo!.deviceName = deviceName;
        telemetry.deviceInfo!.serialNumber = serialNumber;
        telemetry.deviceInfo!.hardwareVersion = hardwareVersion;
        telemetry.deviceInfo!.softwareVersion = softwareVersion;
        telemetry.deviceInfo!.maxMspParameter = maxMspParameter;
        telemetry.deviceInfo!.parameterVersion = parameterVersion;
        telemetry.deviceInfo!.update();
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

  static int convertUint8ToInt8(int value) {
    if (value > 127) {
      return value - 256;
    }
    return value;
  }

  static int convertRfMode(int rfMode) {
    switch (rfMode) {
      case 0:
        return 500;
      case 1:
        return 250;
      case 2: //50 2.4GHz, 50 Low Band
        return 50;
      case 3: //100 Low Band
        return 100;
      case 4: //X100 Full, 100 Full 2.4GHz, 100 Full Low Band
        return 100;
      case 5: //X150, 150 2.4GHz
        return 150;
      case 6: //200 Low Band
        return 200;
      case 7: //250 Low Band
        return 250;
      case 8: // 333 Full 2.4GHz
        return 333;
      case 9: //500 2.4GHz
        return 500;
      case 15: //200 Full Low Band
        return 200;
      case 16: //DK 500 2.4GHz
        return 500;
      case 19: //K1000 Full Low Band
        return 1000;
      default:
        return -1;
    }
  }

  static int convertRfPower(int rfPower) {
    switch (rfPower) {
      case 0:
        return 0;
      case 1:
        return 10;
      case 2:
        return 25;
      case 3:
        return 100;
      case 4:
        return 500;
      case 5:
        return 1000;
      case 6:
        return 2000;
      case 7:
        return 250;
      case 8:
        return 50;
      default:
        return -1;
    }
  }
}
