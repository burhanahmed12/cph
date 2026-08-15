import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';

class RatingScreen extends StatefulWidget {
  final ServiceRequest request;

  const RatingScreen({super.key, required this.request});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 5.0;
  double _tipAmount = 5.0;
  final TextEditingController _reviewController = TextEditingController();

  Future<void> _submitRating() async {
    final reqProv = Provider.of<RequestProvider>(context, listen: false);
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    await reqProv.submitRating(
      requestId: widget.request.id,
      providerId: widget.request.providerId ?? 'prov_01',
      customerName: authProv.customerName,
      rating: _rating,
      reviewText: _reviewController.text.trim(),
      tipAmount: _tipAmount,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for rating your service! ⭐')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Completed Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=256',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.request.providerName ?? 'Alexander Wright',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.request.categoryName} Service',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 24),

            // Star Rating Picker
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final int starValue = index + 1;
                return IconButton(
                  iconSize: 38,
                  icon: Icon(
                    starValue <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = starValue.toDouble();
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 24),

            // Tip Selection Chips
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add a Tip for Provider (Optional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [0.0, 2.0, 5.0, 10.0].map((tip) {
                final bool isSelected = _tipAmount == tip;
                return ChoiceChip(
                  label: Text(tip == 0 ? 'No Tip' : '\$${tip.toStringAsFixed(0)}'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (sel) {
                    if (sel) {
                      setState(() {
                        _tipAmount = tip;
                      });
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Written Feedback
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Share details about the work done, punctuality, and quality...',
                labelText: 'Write a review',
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitRating,
                child: const Text('Submit Rating & Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
