import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class ImageUploader extends StatefulWidget {
  final List<String> selectedPhotos;
  final Function(List<String> updatedPhotos) onPhotosChanged;

  const ImageUploader({
    super.key,
    required this.selectedPhotos,
    required this.onPhotosChanged,
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _photos = [];

  final List<String> _samplePresets = [
    'https://images.unsplash.com/photo-1558402529-d2638a7023e9?auto=format&fit=crop&q=80&w=600',
    'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?auto=format&fit=crop&q=80&w=600',
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&q=80&w=600',
  ];

  @override
  void initState() {
    super.initState();
    _photos.addAll(widget.selectedPhotos);
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _photos.add(image.path);
        });
        widget.onPhotosChanged(_photos);
      }
    } catch (e) {
      debugPrint('[ImageUploader] Gallery pick error: $e');
    }
  }

  void _addSamplePreset(String url) {
    if (!_photos.contains(url)) {
      setState(() {
        _photos.add(url);
      });
      widget.onPhotosChanged(_photos);
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
    widget.onPhotosChanged(_photos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attach Issue Photos',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_photos.length} attached',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Photo Grid & Pick Buttons
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add Button
              InkWell(
                onTap: _pickImageFromGallery,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 90,
                  height: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Attached Photo Thumbnails
              ..._photos.asMap().entries.map((entry) {
                final int idx = entry.key;
                final String path = entry.value;
                final bool isNetwork = path.startsWith('http');

                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                        image: DecorationImage(
                          image: isNetwork
                              ? NetworkImage(path) as ImageProvider
                              : AssetImage(path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 14,
                      child: GestureDetector(
                        onTap: () => _removePhoto(idx),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xB3000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Quick sample photo presets for instant testing
        Wrap(
          spacing: 6,
          children: [
            const Text(
              'Sample Photos:',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () => _addSamplePreset(_samplePresets[0]),
              child: const Text(
                '+ Wiring Photo',
                style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
            const Text('•', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            GestureDetector(
              onTap: () => _addSamplePreset(_samplePresets[1]),
              child: const Text(
                '+ Pipe Leak',
                style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        )
      ],
    );
  }
}
