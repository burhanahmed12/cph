import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_provider_model.dart';

enum UserRole { customer, provider }

class AuthProvider extends ChangeNotifier {
  static const String _roleKey = 'fixnear_user_role';

  UserRole _currentRole = UserRole.customer;
  String _customerName = 'John Customer';
  String _customerPhone = '+1 555-0199';
  String _customerId = 'cust_01';

  ServiceProviderModel _currentProvider = ServiceProviderModel(
    id: 'prov_01',
    name: 'Alexander Wright',
    title: 'Master Electrician',
    categoryId: 'cat_electrician',
    rating: 4.9,
    completedJobs: 142,
    avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256',
    bio: 'Licensed electrician with 8+ years experience in residential wiring and smart home setups.',
    hourlyRate: 55.0,
    skills: ['Smart Switches', 'Breaker Box Upgrade', 'EV Charger Install'],
    isVerified: true,
    phone: '+1 555-0192',
    latitude: 37.7790,
    longitude: -122.4180,
  );

  AuthProvider() {
    _loadRoleFromPrefs();
  }

  UserRole get currentRole => _currentRole;
  bool get isCustomer => _currentRole == UserRole.customer;
  bool get isProvider => _currentRole == UserRole.provider;

  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get customerId => _customerId;
  ServiceProviderModel get currentProvider => _currentProvider;

  Future<void> _loadRoleFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString(_roleKey);
      if (savedRole == 'provider') {
        _currentRole = UserRole.provider;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setRole(UserRole role) async {
    _currentRole = role;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role == UserRole.provider ? 'provider' : 'customer');
    } catch (_) {}
  }

  void switchRole() {
    if (_currentRole == UserRole.customer) {
      setRole(UserRole.provider);
    } else {
      setRole(UserRole.customer);
    }
  }
}
