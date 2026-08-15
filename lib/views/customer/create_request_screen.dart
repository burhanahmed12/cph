import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/service_category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_location_picker.dart';
import '../../widgets/image_uploader.dart';
import 'request_tracking_screen.dart';

class CreateRequestScreen extends StatefulWidget {
  final ServiceCategory? preSelectedCategory;

  const CreateRequestScreen({super.key, this.preSelectedCategory});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  late ServiceCategory _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  
  double _selectedLat = 37.7749;
  double _selectedLng = -122.4194;
  String _selectedAddress = '742 Market Street, San Francisco, CA';

  List<String> _attachedPhotoUrls = [];
  bool _isUrgent = false;
  double _estimatedCost = 55.0;

  @override
  void initState() {
    super.initState();
    final reqProv = Provider.of<RequestProvider>(context, listen: false);
    _selectedCategory = widget.preSelectedCategory ??
        (reqProv.categories.isNotEmpty ? reqProv.categories.first : reqProv.categories[0]);
    _recalculateCost();
  }

  void _recalculateCost() {
    setState(() {
      _estimatedCost = _selectedCategory.startingPrice + (_isUrgent ? 25.0 : 0.0);
    });
  }

  Future<void> _submitRequest() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the service required.')),
      );
      return;
    }

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final reqProv = Provider.of<RequestProvider>(context, listen: false);

    final createdReq = await reqProv.createNewRequest(
      categoryId: _selectedCategory.id,
      categoryName: _selectedCategory.name,
      description: _descriptionController.text.trim(),
      photoUrls: _attachedPhotoUrls,
      latitude: _selectedLat,
      longitude: _selectedLng,
      address: _selectedAddress,
      isUrgent: _isUrgent,
      estimatedCost: _estimatedCost,
      customerId: authProv.customerId,
      customerName: authProv.customerName,
      customerPhone: authProv.customerPhone,
    );

    if (createdReq != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RequestTrackingScreen(request: createdReq),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reqProv = Provider.of<RequestProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selection Header
            const Text(
              'Select Service Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: reqProv.categories.length,
                itemBuilder: (context, index) {
                  final cat = reqProv.categories[index];
                  final bool isSel = cat.id == _selectedCategory.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(
                        cat.icon,
                        size: 18,
                        color: isSel ? Colors.white : cat.categoryColor,
                      ),
                      label: Text(cat.name),
                      selected: isSel,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                          _recalculateCost();
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Description Input
            const Text(
              'Job Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Living room light flickering, socket not working or pipe leaking water...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ),

            const SizedBox(height: 20),

            // Map Location Picker
            const Text(
              'Select Location on Map',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            MapLocationPicker(
              initialLat: _selectedLat,
              initialLng: _selectedLng,
              initialAddress: _selectedAddress,
              onLocationSelected: (lat, lng, address) {
                setState(() {
                  _selectedLat = lat;
                  _selectedLng = lng;
                  _selectedAddress = address;
                });
              },
            ),

            const SizedBox(height: 20),

            // Photo Uploader Widget
            ImageUploader(
              selectedPhotos: _attachedPhotoUrls,
              onPhotosChanged: (photos) {
                setState(() {
                  _attachedPhotoUrls = photos;
                });
              },
            ),

            const SizedBox(height: 20),

            // Priority Switch & Price Estimate Box
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Urgent Request (Immediate Dispatch)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Prioritizes quick dispatch (+ \$25 urgency fee)',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      value: _isUrgent,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _isUrgent = val;
                        });
                        _recalculateCost();
                      },
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Cost Range',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Text(
                              'Final pay based on work completion',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        Text(
                          '\$${_estimatedCost.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: reqProv.isLoading ? null : _submitRequest,
                child: reqProv.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'Confirm & Request Service',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
