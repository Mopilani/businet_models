import '../accounting/payment_method_model.dart';

class ReceiptPaymentMethodEntryModel {
  ReceiptPaymentMethodEntryModel(
    this.id, {
    required this.value,
    required this.paymentMethod,
  });

  int id;
  PaymentMethodModel paymentMethod;
  double value;

  Map<String, dynamic> toMap() => {
        'id': id,
        'paymentMethod': paymentMethod.toMap(),
        'value': value,
      };

  static ReceiptPaymentMethodEntryModel fromMap(Map<String, dynamic> data) {
    return ReceiptPaymentMethodEntryModel(
      data['id'],
      paymentMethod: PaymentMethodModel.fromMap(data['paymentMethod']),
      value: data['value'],
    );
  }
}

class BillPaymentMethodEntryModel {
  BillPaymentMethodEntryModel(
    this.id, {
    required this.value,
    required this.paymentMethod,
  });

  int id;
  PaymentMethodModel paymentMethod;
  double value;

  Map<String, dynamic> toMap() => {
        'id': id,
        'paymentMethod': paymentMethod.toMap(),
        'value': value,
      };

  static BillPaymentMethodEntryModel fromMap(Map<String, dynamic> data) {
    return BillPaymentMethodEntryModel(
      data['id'],
      paymentMethod: PaymentMethodModel.fromMap(data['paymentMethod']),
      value: data['value'],
    );
  }
}
