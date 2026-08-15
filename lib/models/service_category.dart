import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final double startingPrice;
  final String popularTag;
  final Color categoryColor;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.startingPrice,
    this.popularTag = '',
    this.categoryColor = const Color(0xFF4F46E5),
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startingPrice': startingPrice,
      'popularTag': popularTag,
    };
  }
}
