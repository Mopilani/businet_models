enum ScanState {
  scanning,
  scanned,
  noScanOperation,
}


Map<dynamic, String> billStatesTranslations = {
  BillState.canceled: 'ملغية',
  BillState.onWait: 'في الانتظار',
  BillState.partialPay: 'مدفوعة جزئيا',
  BillState.payed: 'مدفوعة',
  BillState.returned: 'راجعة',
  'BillState.canceled': 'ملغية',
  'BillState.onWait': 'في الانتظار',
  'BillState.partialPay': 'مدفوعة جزئيا',
  'BillState.payed': 'مدفوعة',
  'BillState.returned': 'راجعة',
};

Map<dynamic, String> billTypesTranslations = {
  BillType.goodsReceived: 'استلام بضاعة',
  BillType.purchaseOrder: 'امر شراء',
  BillType.sellOrder: 'امر بيع',
  'BillType.goodsReceived': 'استلام بضاعة',
  'BillType.purchaseOrder': 'امر شراء',
  'BillType.sellOrder': 'امر بيع',
};

enum BillState {
  payed,
  onWait,
  returned,
  canceled,
  partialPay,
}

BillState? getBillState(String state) {
  for (var billState in BillState.values) {
    if (billState.toString() == state) {
      return billState;
    }
  }
  return null;
}

BillType getNativeType(String name) {
  switch (name) {
    case 'BillType.purchaseOrder':
      return BillType.purchaseOrder;
    case 'BillType.goodsReceived':
      return BillType.goodsReceived;
    case 'BillType.sellOrder':
      return BillType.sellOrder;
    default:
      throw 'Unknown Bill Type $name';
  }
}

enum BillType {
  purchaseOrder,
  goodsReceived,
  sellOrder,
}

enum CreditType {
  credit,
  slfia,
  workerSalary,
  purchasesInvoice,
}


CreditType? getCreditType(String state) {
  for (var creditType in CreditType.values) {
    if (creditType.toString() == state) {
      return creditType;
    }
  }
  return null;
}

enum TaskState {
  done,
  faild,
  waiting,
  canceld,
  frozed,
}

// class TaskMKN {
//   static const String id = 'id';
//   static const String title = 't';
//   static const String content = 'c';
//   static const String from = 'f';
//   static const String state = 'ts';
//   static const String createTime = 'ct';
//   static const String readTime = 'rt';
//   static const String recieveTime = 'rct';
// }
