import 'dart:async';
import 'package:flutter/material.dart';
import '../models/service_category.dart';
import '../models/service_request.dart';
import '../models/service_provider_model.dart';
import '../models/rating_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class RequestProvider extends ChangeNotifier {
  final ApiService _apiService;
  final NotificationService _notificationService;

  List<ServiceCategory> _categories = [];
  List<ServiceRequest> _customerRequests = [];
  List<ServiceProviderModel> _providers = [];
  
  ServiceCategory? _selectedCategory;
  ServiceRequest? _activeTrackingRequest;

  bool _isLoading = false;
  String? _errorMessage;

  Timer? _locationSimulationTimer;

  RequestProvider({
    required ApiService apiService,
    required NotificationService notificationService,
  })  : _apiService = apiService,
        _notificationService = notificationService {
    fetchInitialData();
  }

  List<ServiceCategory> get categories => _categories;
  List<ServiceRequest> get customerRequests => _customerRequests;
  List<ServiceProviderModel> get providers => _providers;
  ServiceCategory? get selectedCategory => _selectedCategory;
  ServiceRequest? get activeTrackingRequest => _activeTrackingRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _apiService.getCategories();
      _customerRequests = await _apiService.getServiceRequests(customerId: 'cust_01');
      _providers = await _apiService.getProviders();

      if (_customerRequests.isNotEmpty) {
        _activeTrackingRequest = _customerRequests.firstWhere(
          (r) => r.status != RequestStatus.completed && r.status != RequestStatus.cancelled,
          orElse: () => _customerRequests.first,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load initial data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(ServiceCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setActiveTrackingRequest(ServiceRequest request) {
    _activeTrackingRequest = request;
    if (request.status == RequestStatus.enRoute || request.status == RequestStatus.inProgress) {
      _startLiveProviderSimulation(request);
    }
    notifyListeners();
  }

  Future<ServiceRequest?> createNewRequest({
    required String categoryId,
    required String categoryName,
    required String description,
    required List<String> photoUrls,
    required double latitude,
    required double longitude,
    required String address,
    required bool isUrgent,
    required double estimatedCost,
    required String customerId,
    required String customerName,
    required String customerPhone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ServiceRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: categoryId,
        categoryName: categoryName,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        status: RequestStatus.pending,
        description: description,
        photoUrls: photoUrls,
        latitude: latitude,
        longitude: longitude,
        address: address,
        isUrgent: isUrgent,
        estimatedCost: estimatedCost,
        createdAt: DateTime.now(),
      );

      final created = await _apiService.createRequest(request);
      _customerRequests.insert(0, created);
      _activeTrackingRequest = created;

      _notificationService.addNotification(
        title: 'Service Request Created',
        message: 'Your request for $categoryName has been dispatched to nearby providers.',
        requestId: created.id,
      );

      // Auto-simulate provider acceptance after 6 seconds for rich UX
      _simulateProviderAutoAcceptance(created.id);

      return created;
    } catch (e) {
      _errorMessage = 'Failed to create request: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _simulateProviderAutoAcceptance(String requestId) {
    Timer(const Duration(seconds: 5), () async {
      final index = _customerRequests.indexWhere((r) => r.id == requestId);
      if (index != -1 && _customerRequests[index].status == RequestStatus.pending) {
        final updated = await _apiService.updateRequestStatus(
          requestId: requestId,
          newStatus: RequestStatus.accepted,
          providerId: 'prov_01',
          providerName: 'Alexander Wright',
          providerPhone: '+1 555-0192',
          providerLat: _customerRequests[index].latitude + 0.008,
          providerLng: _customerRequests[index].longitude + 0.008,
        );

        _customerRequests[index] = updated;
        if (_activeTrackingRequest?.id == requestId) {
          _activeTrackingRequest = updated;
        }

        _notificationService.addNotification(
          title: 'Job Accepted! 🛠️',
          message: 'Alexander Wright accepted your service request!',
          requestId: requestId,
        );

        notifyListeners();
      }
    });
  }

  void _startLiveProviderSimulation(ServiceRequest request) {
    _locationSimulationTimer?.cancel();
    double currentLat = request.providerLat ?? (request.latitude + 0.008);
    double currentLng = request.providerLng ?? (request.longitude + 0.008);

    _locationSimulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_activeTrackingRequest?.id != request.id ||
          (_activeTrackingRequest?.status != RequestStatus.enRoute &&
              _activeTrackingRequest?.status != RequestStatus.inProgress)) {
        timer.cancel();
        return;
      }

      // Smooth step towards target customer location
      currentLat += (request.latitude - currentLat) * 0.15;
      currentLng += (request.longitude - currentLng) * 0.15;

      _activeTrackingRequest?.providerLat = currentLat;
      _activeTrackingRequest?.providerLng = currentLng;
      notifyListeners();
    });
  }

  Future<void> submitRating({
    required String requestId,
    required String providerId,
    required String customerName,
    required double rating,
    required String reviewText,
    required double tipAmount,
  }) async {
    final serviceRating = ServiceRating(
      id: 'rate_${DateTime.now().millisecondsSinceEpoch}',
      requestId: requestId,
      customerName: customerName,
      providerId: providerId,
      rating: rating,
      reviewText: reviewText,
      tipAmount: tipAmount,
      createdAt: DateTime.now(),
    );

    await _apiService.submitRating(serviceRating);

    final index = _customerRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _customerRequests[index].ratingScore = rating;
      _customerRequests[index].ratingComment = reviewText;
      _customerRequests[index].tipAmount = tipAmount;
    }

    _notificationService.addNotification(
      title: 'Rating Submitted ⭐',
      message: 'Thank you for rating your service experience!',
      requestId: requestId,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _locationSimulationTimer?.cancel();
    super.dispose();
  }
}
