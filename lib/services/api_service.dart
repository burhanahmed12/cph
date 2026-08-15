import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_category.dart';
import '../models/service_provider_model.dart';
import '../models/service_request.dart';
import '../models/rating_model.dart';
import '../models/earning_summary.dart';
import 'mock_data.dart';
import 'firebase_service.dart';

class ApiService {
  static const String _requestsKey = 'fixnear_requests_cache';
  static const String _ratingsKey = 'fixnear_ratings_cache';

  List<ServiceRequest> _requests = [];
  List<ServiceRating> _ratings = [];

  ApiService() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsString = prefs.getString(_requestsKey);
      if (requestsString != null && requestsString.isNotEmpty) {
        final List jsonList = jsonDecode(requestsString);
        _requests = jsonList.map((item) => ServiceRequest.fromJson(item)).toList();
      } else {
        _requests = List.from(MockData.initialRequests);
        await _saveRequestsToStorage();
      }

      final ratingsString = prefs.getString(_ratingsKey);
      if (ratingsString != null && ratingsString.isNotEmpty) {
        final List jsonList = jsonDecode(ratingsString);
        _ratings = jsonList.map((item) => ServiceRating.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('[ApiService] Storage initialization error: $e');
      _requests = List.from(MockData.initialRequests);
    }
  }

  Future<void> _saveRequestsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _requests.map((r) => r.toJson()).toList();
      await prefs.setString(_requestsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[ApiService] Save requests error: $e');
    }
  }

  Future<void> _saveRatingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _ratings.map((r) => r.toJson()).toList();
      await prefs.setString(_ratingsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[ApiService] Save ratings error: $e');
    }
  }

  // --- REST API Endpoints ---

  /// GET /api/v1/categories
  Future<List<ServiceCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.categories;
  }

  /// GET /api/v1/providers
  Future<List<ServiceProviderModel>> getProviders({String? categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (categoryId == null || categoryId.isEmpty) {
      return MockData.providers;
    }
    return MockData.providers
        .where((p) => p.categoryId == categoryId)
        .toList();
  }

  /// GET /api/v1/providers/:id
  Future<ServiceProviderModel?> getProviderById(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return MockData.providers.firstWhere((p) => p.id == providerId);
    } catch (_) {
      return null;
    }
  }

  /// GET /api/v1/requests
  Future<List<ServiceRequest>> getServiceRequests({
    String? customerId,
    String? providerId,
    RequestStatus? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    Iterable<ServiceRequest> filtered = _requests;

    if (customerId != null && customerId.isNotEmpty) {
      filtered = filtered.where((r) => r.customerId == customerId);
    }

    if (providerId != null && providerId.isNotEmpty) {
      filtered = filtered.where((r) => r.providerId == providerId || r.providerId == null);
    }

    if (status != null) {
      filtered = filtered.where((r) => r.status == status);
    }

    return filtered.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// POST /api/v1/requests
  Future<ServiceRequest> createRequest(ServiceRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _requests.insert(0, request);
    await _saveRequestsToStorage();

    // Mirror to Firebase if initialized
    await FirebaseService.createFirestoreRequest(request);

    return request;
  }

  /// PUT /api/v1/requests/:id/status
  Future<ServiceRequest> updateRequestStatus({
    required String requestId,
    required RequestStatus newStatus,
    String? providerId,
    String? providerName,
    String? providerPhone,
    double? providerLat,
    double? providerLng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final req = _requests[index];
    req.status = newStatus;
    if (providerId != null) req.providerId = providerId;
    if (providerName != null) req.providerName = providerName;
    if (providerPhone != null) req.providerPhone = providerPhone;
    if (providerLat != null) req.providerLat = providerLat;
    if (providerLng != null) req.providerLng = providerLng;
    if (newStatus == RequestStatus.completed) {
      req.completedAt = DateTime.now();
    }

    _requests[index] = req;
    await _saveRequestsToStorage();

    await FirebaseService.updateFirestoreRequestStatus(
      requestId: requestId,
      status: newStatus,
      providerId: providerId,
      providerName: providerName,
    );

    return req;
  }

  /// POST /api/v1/ratings
  Future<void> submitRating(ServiceRating rating) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _ratings.add(rating);
    await _saveRatingsToStorage();

    // Update rating on request object
    final index = _requests.indexWhere((r) => r.id == rating.requestId);
    if (index != -1) {
      _requests[index].ratingScore = rating.rating;
      _requests[index].ratingComment = rating.reviewText;
      _requests[index].tipAmount = rating.tipAmount;
      await _saveRequestsToStorage();
    }

    await FirebaseService.submitFirestoreRating(rating);
  }

  /// GET /api/v1/providers/:id/earnings
  Future<EarningSummary> getProviderEarnings(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final completedJobs = _requests.where(
      (r) => (r.providerId == providerId || r.providerId != null) && r.status == RequestStatus.completed,
    ).toList();

    double totalEarnings = 0.0;
    for (var job in completedJobs) {
      totalEarnings += job.estimatedCost + (job.tipAmount ?? 0.0);
    }

    // Default mock figures for dashboard realism
    double today = completedJobs.isEmpty ? 140.0 : totalEarnings * 0.4;
    double weekly = completedJobs.isEmpty ? 680.0 : totalEarnings * 0.8;
    double monthly = completedJobs.isEmpty ? 2450.0 : totalEarnings * 2.5;

    return EarningSummary(
      todayEarnings: today,
      weeklyEarnings: weekly,
      monthlyEarnings: monthly,
      completedJobsCount: completedJobs.length > 0 ? completedJobs.length : 18,
      averageRating: 4.9,
      hoursWorked: 32.5,
    );
  }
}
