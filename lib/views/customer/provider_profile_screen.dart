import 'package:flutter/material.dart';
import '../../models/service_provider_model.dart';
import '../../theme/app_theme.dart';
import 'create_request_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  final ServiceProviderModel provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundImage: NetworkImage(provider.avatarUrl),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 20),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.title,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Rating', '⭐ ${provider.rating}'),
                        _buildStatItem('Jobs Done', '${provider.completedJobs}+'),
                        _buildStatItem('Hourly Rate', '\$${provider.hourlyRate.toStringAsFixed(0)}/hr'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bio Section
            const Text(
              'About Provider',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.bio,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Skills & Certifications
            const Text(
              'Skills & Services',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.skills.map((skill) {
                return Chip(
                  avatar: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                  label: Text(skill),
                  backgroundColor: AppColors.primaryLight,
                  side: BorderSide.none,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Customer Reviews Header & Sample Review
            const Text(
              'Recent Client Reviews',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text('EM', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Emily R.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        Text('5.0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    '"Arrived within 15 minutes! Diagnosed the electrical issue immediately and fixed everything cleanly. Highly recommend!"',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateRequestScreen()),
                  );
                },
                icon: const Icon(Icons.handyman_rounded, color: Colors.white),
                label: Text('Book ${provider.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
