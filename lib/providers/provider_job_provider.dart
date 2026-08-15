import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../models/earning_summary.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ProviderJobProvider extends ChangeNotifier {
  final ApiService _apiService;
  final NotificationService _notificationService;

  bool _isOnline = true;
  List<ServiceRequest> _incomingJobs = [];
  List<ServiceRequest> _activeAndPastJobs = [];
  ServiceRequest? _currentActiveJob;
  EarningSummary? _earnings;

  bool _isLoading = false;

  ProviderJobProvider({
    required ApiService apiService,
    required NotificationService notificationService,
  })  : _apiService = apiService,
        _notificationService = notificationService {
    fetchProviderDashboardData('prov_01');
  }

  bool get isOnline => _isOnline;
  List<ServiceRequest> get incomingJobs => _incomingJobs;
  List<ServiceRequest> get activeAndPastJobs => _activeAndPastJobs;
  ServiceRequest? get currentActiveJob => _currentActiveJob;
  EarningSummary? get earnings => _earnings;
  bool get isLoading => _isLoading;

  void toggleOnlineState() {
    _isOnline = !_isOnline;
    _notificationService.addNotification(
      title: _isOnline ? 'You are Online 🟢' : 'You are Offline 🔴',
      message: _isOnline ? 'Receiving service requests in your area.' : 'Job dispatch paused.',
    );
    notifyListeners();
  }

  Future<void> fetchProviderDashboardData(String providerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final allRequests = await _apiService.getServiceRequests();
      
      _incomingJobs = allRequests
          .where((r) => r.status == RequestStatus.pending)
          .toList();

      _activeAndPastJobs = allRequests
          .where((r) => r.providerId == providerId || r.providerId == null)
          .toList();

      if (_activeAndPastJobs.isNotEmpty) {
        try {
          _currentActiveJob = _activeAndPastJobs.firstWhere(
            (r) => r.status == RequestStatus.accepted ||
                r.status == RequestStatus.enRoute ||
                r.status == RequestStatus.inProgress,
          );
        } catch (_) {
          _currentActiveJob = null;
        }
      }

      _earnings = await _apiService.getProviderEarnings(providerId);
    } catch (e) {
      debugPrint('[ProviderJobProvider] Load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptJob(ServiceRequest request, String providerId, String providerName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateRequestStatus(
        requestId: request.id,
        newStatus: RequestStatus.accepted,
        providerId: providerId,
        providerName: providerName,
        providerPhone: '+1 555-0192',
        providerLat: request.latitude + 0.006,
        providerLng: request.longitude + 0.006,
      );

      _incomingJobs.removeWhere((r) => r.id == request.id);
      _currentActiveJob = updated;

      _notificationService.addNotification(
        title: 'Job Accepted! 🛠️',
        message: 'Proceed to ${request.address}',
        requestId: request.id,
      );

      await fetchProviderDashboardData(providerId);
    } catch (e) {
      debugPrint('[ProviderJobProvider] Accept error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobWorkflow(RequestStatus nextStatus) async {
    if (_currentActiveJob == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _apiService.updateRequestStatus(
        requestId: _currentActiveJob!.id,
        newStatus: nextStatus,
      );

      _currentActiveJob = updated;

      String msg = '';
      if (nextStatus == RequestStatus.enRoute) {
        msg = 'Status updated: On the way to customer.';
      } else if (nextStatus == RequestStatus.inProgress) {
        msg = 'Status updated: Service work started.';
      } else if (nextStatus == RequestStatus.completed) {
        msg = 'Job completed! Payment added to your earnings.';
        _currentActiveJob = null;
      }

      _notificationService.addNotification(
        title: 'Workflow Update',
        message: msg,
        requestId: updated.id,
      );

      await fetchProviderDashboardData('prov_01');
    } catch (e) {
      debugPrint('[ProviderJobProvider] Workflow error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
