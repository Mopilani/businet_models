enum ScanState {
  scanning,
  scanned,
  noScanOperation,
}

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

enum BillType {
  purchaseOrder,
  goodsReceived,
  sellOrder,
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

Map<dynamic, String> billTypesTranslations = {
  BillType.goodsReceived: 'استلام بضاعة',
  BillType.purchaseOrder: 'امر شراء',
  BillType.sellOrder: 'امر بيع',
  'BillType.goodsReceived': 'استلام بضاعة',
  'BillType.purchaseOrder': 'امر شراء',
  'BillType.sellOrder': 'امر بيع',
};

enum CreditType {
  income,
  outcome
  // credit,
  // slfia,
  // workerSalary,
  // purchasesInvoice,
}

Map<dynamic, String> creditTypeTranslations = {
  CreditType.income: 'قبض',
  CreditType.outcome: 'صرف',
  'CreditType.income': 'قبض',
  'CreditType.outcome': 'صرف',
};

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

TaskState? getTaskState(String state) {
  for (var creditType in TaskState.values) {
    if (creditType.toString() == state) {
      return creditType;
    }
  }
  return null;
}

Map<dynamic, String> taskStatesTranslations = {
  TaskState.done: 'تم',
  'TaskState.done': 'تم',
  TaskState.faild: 'فشلت',
  'TaskState.faild': 'فشلت',
  TaskState.waiting: 'في الانتظار',
  'TaskState.waiting': 'في الانتظار',
  TaskState.canceld: 'تم الاللغاء',
  'TaskState.canceld': 'تم الاللغاء',
  TaskState.frozed: 'مجمدة',
  'TaskState.frozed': 'مجمدة',
};

enum TransactionType {
  outcome,
  income,
}

TransactionType transTypeFromString(String typeStr) {
  switch (typeStr) {
    case 'TransactionType.income':
      return TransactionType.income;
    case 'TransactionType.outcome':
      return TransactionType.outcome;
    default:
      throw 'Main Axis Alignment, Error Happend مقصودة';
  }
}

Map<dynamic, String> transactionsTranslations = {
  TransactionType.income: 'دخل',
  'TransactionType.income': 'دخل',
  TransactionType.outcome: 'منصرف',
  'TransactionType.outcome': 'منصرف',
};

enum ReceiptState {
  payed,
  onWait,
  returned,
  canceled,
  partialPay,
}

Map<dynamic, String> receiptStatesTranslations = {
  ReceiptState.canceled: 'ملغية',
  ReceiptState.onWait: 'في الانتظار',
  ReceiptState.partialPay: 'مدفوعة جزئيا',
  ReceiptState.payed: 'مدفوعة',
  ReceiptState.returned: 'راجعة',
  'BillState.canceled': 'ملغية',
  'BillState.onWait': 'في الانتظار',
  'BillState.partialPay': 'مدفوعة جزئيا',
  'BillState.payed': 'مدفوعة',
  'BillState.returned': 'راجعة',
};

ReceiptState? getReceiptState(String state) {
  for (var billState in ReceiptState.values) {
    if (billState.toString() == state) {
      return billState;
    }
  }
  return null;
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
