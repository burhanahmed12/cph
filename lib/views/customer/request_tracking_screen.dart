import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service_request.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/live_tracking_map.dart';
import '../../widgets/status_badge.dart';
import 'rating_screen.dart';

class RequestTrackingScreen extends StatelessWidget {
  final ServiceRequest request;

  const RequestTrackingScreen({super.key, required this.request});

  Future<void> _callProvider(BuildContext context, String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Calling $phone...')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Calling provider: $phone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reqProv = Provider.of<RequestProvider>(context);
    final currentReq = reqProv.customerRequests.firstWhere(
      (r) => r.id == request.id,
      orElse: () => request,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentReq.categoryName} Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => reqProv.fetchInitialData(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Live Interactive Map Widget
            LiveTrackingMap(request: currentReq, height: 320),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: currentReq.status),
                      Text(
                        '\$${currentReq.estimatedCost.toStringAsFixed(0)} Est.',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Job Workflow Progress Stepper Bar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Request Timeline',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          _buildStatusStepRow('1', 'Request Created', true),
                          _buildStatusStepRow(
                            '2',
                            'Provider Assigned',
                            currentReq.status != RequestStatus.pending,
                          ),
                          _buildStatusStepRow(
                            '3',
                            'Provider En Route',
                            currentReq.status == RequestStatus.enRoute ||
                                currentReq.status == RequestStatus.inProgress ||
                                currentReq.status == RequestStatus.completed,
                          ),
                          _buildStatusStepRow(
                            '4',
                            'Work In Progress',
                            currentReq.status == RequestStatus.inProgress ||
                                currentReq.status == RequestStatus.completed,
                          ),
                          _buildStatusStepRow(
                            '5',
                            'Completed',
                            currentReq.status == RequestStatus.completed,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Service Provider Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentReq.providerName ?? 'Alexander Wright',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Certified ${currentReq.categoryName} • ⭐ 4.9',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                            onPressed: () => _callProvider(context, currentReq.providerPhone ?? '+1 555-0192'),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening chat with provider...')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Job Details & Address Box
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Location',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentReq.address,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const Divider(height: 20),
                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentReq.description,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rating Button (active when job completed)
                  if (currentReq.status == RequestStatus.completed)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                        icon: const Icon(Icons.star_rounded, color: Colors.white),
                        label: const Text('Rate & Review Service', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RatingScreen(request: currentReq),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepRow(String stepNum, String title, bool isDone, {bool isLast = false}) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : AppColors.cardBorder,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : Text(
                        stepNum,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 18,
                color: isDone ? AppColors.primary : AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
            color: isDone ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
