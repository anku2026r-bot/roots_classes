class PaymentOrderModel {
  final String orderId;
  final int amount; // in paise
  final String currency;
  final String keyId;
  final String enrollmentId;
  final double finalPrice;
  final double discountApplied;

  const PaymentOrderModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.enrollmentId,
    required this.finalPrice,
    this.discountApplied = 0.0,
  });

  factory PaymentOrderModel.fromJson(Map<String, dynamic> json) {
    final orderObj = json['order'] as Map<String, dynamic>? ?? {};

    return PaymentOrderModel(
      orderId: (orderObj['id'] ?? '') as String,
      amount: (orderObj['amount'] != null ? (orderObj['amount'] as num).toInt() : 0),
      currency: (orderObj['currency'] ?? 'INR') as String,
      keyId: (json['keyId'] ?? '') as String,
      enrollmentId: (json['enrollmentId'] ?? '') as String,
      finalPrice: (json['finalPrice'] != null ? (json['finalPrice'] as num).toDouble() : 0.0),
      discountApplied: (json['discountApplied'] != null
          ? (json['discountApplied'] as num).toDouble()
          : 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': {
        'id': orderId,
        'amount': amount,
        'currency': currency,
      },
      'keyId': keyId,
      'enrollmentId': enrollmentId,
      'finalPrice': finalPrice,
      'discountApplied': discountApplied,
    };
  }
}

class PaymentVerificationResult {
  final bool success;
  final String message;
  final String? receiptUrl;

  const PaymentVerificationResult({
    required this.success,
    required this.message,
    this.receiptUrl,
  });

  factory PaymentVerificationResult.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResult(
      success: json['success'] as bool? ?? true,
      message: (json['message'] ?? '') as String,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }
}

class PurchasedItemModel {
  final String id;
  final String title;

  const PurchasedItemModel({
    required this.id,
    required this.title,
  });

  factory PurchasedItemModel.fromJson(Map<String, dynamic> json) {
    return PurchasedItemModel(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
    };
  }
}
