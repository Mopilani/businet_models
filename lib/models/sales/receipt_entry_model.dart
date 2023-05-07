import 'sku_model.dart';

class ReceiptEntryModel {
  ReceiptEntryModel({
    required this.skuModel,
    required this.quantity,
    required this.total,
    required this.tax,
    required this.deliveryPrice,
  }) {
    skuModel.id;
    skuModel.barcode;
  }
  SKUModel skuModel;
  double deliveryPrice;
  double quantity;
  double total;
  double tax;

  Map<String, dynamic> toMap() => {
        'skuModel': skuModel.toMap(),
        'quantity': quantity,
        'total': total,
        'deliveryPrice': deliveryPrice,
        'tax': tax,
      };

  static ReceiptEntryModel fromMap(Map<String, dynamic> data) {
    return ReceiptEntryModel(
      skuModel: SKUModel.fromMap({...data['skuModel']}),
      quantity: data['quantity'],
      total: data['total'],
      tax: data['tax'],
      deliveryPrice: data['deliveryPrice'],
    );
  }
}
