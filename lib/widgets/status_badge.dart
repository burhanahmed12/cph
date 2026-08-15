import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case RequestStatus.pending:
        color = AppColors.statusPending;
        icon = Icons.hourglass_empty_rounded;
        break;
      case RequestStatus.accepted:
        color = AppColors.statusAccepted;
        icon = Icons.assignment_turned_in_rounded;
        break;
      case RequestStatus.enRoute:
        color = AppColors.statusEnRoute;
        icon = Icons.directions_run_rounded;
        break;
      case RequestStatus.inProgress:
        color = AppColors.statusInProgress;
        icon = Icons.build_circle_rounded;
        break;
      case RequestStatus.completed:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_rounded;
        break;
      case RequestStatus.cancelled:
        color = AppColors.statusCancelled;
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 16, color: color),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
