enum PTPIPPacketType {
  initCommandRequest(0x00000001),
  initCommandAck(0x00000002),
  initEventRequest(0x00000003),
  initEventAck(0x00000004),
  initFail(0x00000005),
  operationRequest(0x00000006),
  operationResponse(0x00000007),
  event(0x00000008),
  startData(0x00000009),
  data(0x0000000A),
  cancel(0x0000000B),
  endData(0x0000000C),
  probeRequest(0x0000000D),
  probeResponse(0x0000000E);

  const PTPIPPacketType(this.rawValue);
  final int rawValue;
}

enum PTPIPDataPhaseInfo {
  noDataOrDataIn(0x00000001),
  dataOut(0x00000002),
  unknown(0x00000003);

  const PTPIPDataPhaseInfo(this.rawValue);
  final int rawValue;
}

enum PTPOperationCode {
  getDeviceInfo(0x1001),
  openSession(0x1002),
  closeSession(0x1003),
  getStorageIDs(0x1004),
  getStorageInfo(0x1005),
  getNumObjects(0x1006),
  getObjectHandles(0x1007),
  getObjectInfo(0x1008),
  getObject(0x1009),
  getThumb(0x100A),
  getPartialObject(0x101B),
  getObjectsMetaData(0x9434);

  const PTPOperationCode(this.rawValue);
  final int rawValue;
}

enum PTPResponseCode {
  ok(0x2001),
  generalError(0x2002),
  sessionNotOpen(0x2003),
  invalidTransactionID(0x2004),
  operationNotSupported(0x2005),
  parameterNotSupported(0x2006),
  incompleteTransfer(0x2007),
  invalidStorageID(0x2008),
  invalidObjectHandle(0x2009),
  devicePropNotSupported(0x200A),
  invalidObjectFormatCode(0x200B),
  storeFull(0x200C),
  objectWriteProtected(0x200D),
  storeReadOnly(0x200E),
  accessDenied(0x200F),
  noThumbnailPresent(0x2010),
  selfTestFailed(0x2011),
  partialDeletion(0x2012),
  storeNotAvailable(0x2013),
  specificationByFormatUnsupported(0x2014),
  noValidObjectInfo(0x2015),
  invalidCodeFormat(0x2016),
  unknownVendorCode(0x2017),
  captureAlreadyTerminated(0x2018),
  deviceBusy(0x2019),
  invalidParentObject(0x201A),
  invalidDevicePropFormat(0x201B),
  invalidDevicePropValue(0x201C),
  invalidParameter(0x201D),
  sessionAlreadyOpen(0x201E),
  transactionCancelled(0x201F),
  specificationOfDestinationUnsupported(0x2020);

  const PTPResponseCode(this.rawValue);
  final int rawValue;
}

class PTPIPBinary {
  PTPIPBinary._();

  static const int protocolVersion = 0x00010000;
  static const String defaultFriendlyName = 'NikonConnectIOS';
}
