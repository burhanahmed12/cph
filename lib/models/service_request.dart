enum RequestStatus {
  pending,
  accepted,
  enRoute,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending Provider';
      case RequestStatus.accepted:
        return 'Job Accepted';
      case RequestStatus.enRoute:
        return 'Provider En Route';
      case RequestStatus.inProgress:
        return 'Work In Progress';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class ServiceRequest {
  final String id;
  final String categoryId;
  final String categoryName;
  final String customerId;
  final String customerName;
  final String customerPhone;
  String? providerId;
  String? providerName;
  String? providerPhone;
  RequestStatus status;
  final String description;
  final List<String> photoUrls;
  final double latitude;
  final double longitude;
  final String address;
  final bool isUrgent;
  final double estimatedCost;
  final DateTime createdAt;
  DateTime? scheduledFor;
  DateTime? completedAt;
  double? providerLat;
  double? providerLng;
  double? ratingScore;
  String? ratingComment;
  double? tipAmount;

  ServiceRequest({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.providerId,
    this.providerName,
    this.providerPhone,
    this.status = RequestStatus.pending,
    required this.description,
    required this.photoUrls,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.isUrgent = false,
    required this.estimatedCost,
    required this.createdAt,
    this.scheduledFor,
    this.completedAt,
    this.providerLat,
    this.providerLng,
    this.ratingScore,
    this.ratingComment,
    this.tipAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'status': status.name,
      'description': description,
      'photoUrls': photoUrls,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isUrgent': isUrgent,
      'estimatedCost': estimatedCost,
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'providerLat': providerLat,
      'providerLng': providerLng,
      'ratingScore': ratingScore,
      'ratingComment': ratingComment,
      'tipAmount': tipAmount,
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? 'Service',
      customerId: json['customerId'] ?? 'cust_01',
      customerName: json['customerName'] ?? 'John Customer',
      customerPhone: json['customerPhone'] ?? '+1 555-0199',
      providerId: json['providerId'],
      providerName: json['providerName'],
      providerPhone: json['providerPhone'],
      status: RequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      description: json['description'] ?? '',
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 37.7749,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -122.4194,
      address: json['address'] ?? 'Selected Location',
      isUrgent: json['isUrgent'] ?? false,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 75.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      providerLat: (json['providerLat'] as num?)?.toDouble(),
      providerLng: (json['providerLng'] as num?)?.toDouble(),
      ratingScore: (json['ratingScore'] as num?)?.toDouble(),
      ratingComment: json['ratingComment'],
      tipAmount: (json['tipAmount'] as num?)?.toDouble(),
    );
  }
}
