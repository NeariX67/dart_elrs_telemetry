enum PacketType {
  unknown(0x00), // 0
  gps(0x02), // 2
  vario(0x07), // 7
  batterySensor(0x08), // 8
  baroAltitude(0x09), // 9
  heartbeat(0x0B), // 11
  videoTransmitter(0x0F), // 15
  opentxSync(0x10), // 16
  linkStatistics(0x14), // 20
  rcChannelsPacked(0x16), // 22
  subsetRcChannelsPacked(0x17), // 23
  linkRxId(0x1C), // 28
  linkTxId(0x1D), // 29
  attitude(0x1E), // 30
  flightMode(0x21), // 33

  // Extended Telemetry
  devicePing(0x28), // 40
  deviceInfo(0x29), // 41
  parameterSettingsEntry(0x2B), // 43
  parameterRead(0x2C), // 44
  parameterWrite(0x2D), // 45
  elrsStatus(0x2E), // 46
  command(0x32), // 50
  radioId(0x3A), // 58
  kissReq(0x78), // 120
  kissResp(0x79), // 121
  mspReq(0x7A), // 122
  mspResp(0x7B), // 123
  mspWrite(0x7C), // 124
  displayportCm(0x7D), // 125
  ardupilotResp(0x80); // 128

  const PacketType(this.value);
  final int value;

  static PacketType fromValue(int value) {
    return PacketType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PacketType.gps,
    );
  }
}

enum CrsfAddress {
  broadcast(0x00), // 0
  usb(0x10), // 16
  bluetooth(0x12), // 18
  tbsCorePnpPro(0x80), // 128
  reserved1(0x8A), // 138
  currentSensor(0xC0), // 192
  gps(0xC2), // 194
  tbsBlackbox(0xC4), // 196
  flightController(0xC8), // 200
  reserved2(0xCA), // 202
  raceTag(0xCC), // 204
  radioTransmitter(0xEA), // 234
  crsfReceiver(0xEC), // 236
  crsfTransmitter(0xEE), // 238
  elrsLua(0xEF); // 239

  const CrsfAddress(this.value);
  final int value;

  static CrsfAddress fromValue(int value) {
    return CrsfAddress.values.firstWhere(
      (address) => address.value == value,
      orElse: () => CrsfAddress.broadcast,
    );
  }
}
