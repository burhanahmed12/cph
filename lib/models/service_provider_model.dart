class ServiceProviderModel {
  final String id;
  final String name;
  final String title;
  final String categoryId;
  final double rating;
  final int completedJobs;
  final String avatarUrl;
  final String bio;
  final double hourlyRate;
  final List<String> skills;
  final bool isVerified;
  final String phone;
  final double latitude;
  final double longitude;

  ServiceProviderModel({
    required this.id,
    required this.name,
    required this.title,
    required this.categoryId,
    required this.rating,
    required this.completedJobs,
    required this.avatarUrl,
    required this.bio,
    required this.hourlyRate,
    required this.skills,
    this.isVerified = true,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'categoryId': categoryId,
      'rating': rating,
      'completedJobs': completedJobs,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'hourlyRate': hourlyRate,
      'skills': skills,
      'isVerified': isVerified,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      categoryId: json['categoryId'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      completedJobs: json['completedJobs'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 45.0,
      skills: List<String>.from(json['skills'] ?? []),
      isVerified: json['isVerified'] ?? true,
      phone: json['phone'] ?? '+1 555-0192',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 37.7749,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -122.4194,
    );
  }
}
