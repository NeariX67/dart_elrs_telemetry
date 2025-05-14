import 'package:flutter/widgets.dart';

class ElrsTelemetry with ChangeNotifier {
  Location? homeLocation;
  UavLocation? uavLocation;
  BatterySensor? batterySensor;
  VideoTransmitter? videoTransmitter;
  LinkStatistics? linkStatistics;
  Attitude? attitude;
  DeviceInfo? deviceInfo;
  AltitudeVario? altitudeVario;

  void update() {
    notifyListeners();
  }
}

class Location with ChangeNotifier {
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

  void update() {
    notifyListeners();
  }
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

class BatterySensor with ChangeNotifier {
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

  void update() {
    notifyListeners();
  }
}

class VideoTransmitter with ChangeNotifier {
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

  void update() {
    notifyListeners();
  }
}

class LinkStatistics with ChangeNotifier {
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

  void update() {
    notifyListeners();
  }
}

class Attitude with ChangeNotifier {
  double roll;
  double pitch;
  double yaw;

  Attitude({required this.roll, required this.pitch, required this.yaw});

  void update() {
    notifyListeners();
  }
}

class DeviceInfo with ChangeNotifier {
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

  void update() {
    notifyListeners();
  }
}

class AltitudeVario with ChangeNotifier {
  double altitude; // m
  double varioSpeed; // m/s

  AltitudeVario({required this.altitude, required this.varioSpeed});

  void update() {
    notifyListeners();
  }
}

// class RadioId {
//   int radioAddress;
//   int timingCorrectionFrame;
//   int updateInterval;
// }
