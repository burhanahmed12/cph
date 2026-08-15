class ServiceRating {
  final String id;
  final String requestId;
  final String customerName;
  final String providerId;
  final double rating;
  final String reviewText;
  final double tipAmount;
  final DateTime createdAt;

  ServiceRating({
    required this.id,
    required this.requestId,
    required this.customerName,
    required this.providerId,
    required this.rating,
    required this.reviewText,
    this.tipAmount = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'customerName': customerName,
      'providerId': providerId,
      'rating': rating,
      'reviewText': reviewText,
      'tipAmount': tipAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ServiceRating.fromJson(Map<String, dynamic> json) {
    return ServiceRating(
      id: json['id'] ?? '',
      requestId: json['requestId'] ?? '',
      customerName: json['customerName'] ?? 'Customer',
      providerId: json['providerId'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewText: json['reviewText'] ?? '',
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
