import 'package:flutter/widgets.dart';

class ElrsTelemetry with ChangeNotifier {
  static Location? homeLocation;
  static UavLocation? uavLocation;
  static BatterySensor? batterySensor;
  static VideoTransmitter? videoTransmitter;
  static LinkStatistics? linkStatistics;
  static Attitude? attitude;
  static DeviceInfo? deviceInfo;

  static double? altitude; // m
  static double? varioSpeed; // m/s
}

class Location {
  double latitude;
  double longitude;
  double altitude;
  double? heading;
  //  double altitudeAboveGround;

  Location({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    this.heading,
    // required this.altitudeAboveGround,
  });
}

class UavLocation extends Location {
  double groundSpeed;
  int gpsSatellites;

  UavLocation({
    required super.latitude,
    required super.longitude,
    required super.altitude,
    super.heading,
    required this.groundSpeed,
    required this.gpsSatellites,
  });
}

class BatterySensor {
  double voltage; // V
  double current; // A
  int capacity; // mAh
  int percentage; // %

  BatterySensor({
    required this.voltage,
    required this.current,
    required this.capacity,
    required this.percentage,
  });
  double get power => voltage * current; // W
}

class VideoTransmitter {
  //I have no idea what these values mean
  int originAddress;
  int status;
  int bandChannel;
  int userFrequency;
  int pitModeAndPower;

  VideoTransmitter({
    required this.originAddress,
    required this.status,
    required this.bandChannel,
    required this.userFrequency,
    required this.pitModeAndPower,
  });
}

class LinkStatistics {
  int uplinkRssi1;
  int uplinkRssi2;
  int uplinkLinkQuality;
  int uplinkSnr;
  int activeAntenna;
  int rfMode;
  int uplinkTxPower;
  int downlinkRssi;
  int downlinkLinkQuality;
  int downlinkSnr;

  LinkStatistics({
    required this.uplinkRssi1,
    required this.uplinkRssi2,
    required this.uplinkLinkQuality,
    required this.uplinkSnr,
    required this.activeAntenna,
    required this.rfMode,
    required this.uplinkTxPower,
    required this.downlinkRssi,
    required this.downlinkLinkQuality,
    required this.downlinkSnr,
  });
}

class Attitude {
  double roll;
  double pitch;
  double yaw;

  Attitude({required this.roll, required this.pitch, required this.yaw});
}

class DeviceInfo {
  int destination;
  int origin;
  String deviceName;
  String serialNumber;
  int hardwareVersion;
  String softwareVersion;
  int maxMspParameter;
  int parameterVersion;

  DeviceInfo({
    required this.destination,
    required this.origin,
    required this.deviceName,
    required this.serialNumber,
    required this.hardwareVersion,
    required this.softwareVersion,
    required this.maxMspParameter,
    required this.parameterVersion,
  });
}

// class RadioId {
//   int radioAddress;
//   int timingCorrectionFrame;
//   int updateInterval;
// }
