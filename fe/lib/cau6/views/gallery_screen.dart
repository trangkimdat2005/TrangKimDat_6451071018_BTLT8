import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/image_item.dart';
import '../data/repository/image_repository.dart';

class Cau6GalleryScreen extends StatefulWidget {
  const Cau6GalleryScreen({super.key});

  @override
  State<Cau6GalleryScreen> createState() => _Cau6GalleryScreenState();
}

class _Cau6GalleryScreenState extends State<Cau6GalleryScreen> {
  final ImageRepository _repository = ImageRepository();
  List<ImageItem> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    final images = await _repository.getAllImages();
    setState(() {
      _images = images;
      _isLoading = false;
    });
  }

  Future<void> _addImage() async {
    final titles = [
      'Cảnh đẹp thiên nhiên',
      'Hoàng hôn trên biển',
      'Thành phố về đêm',
      'Rừng nhiệt đới',
      'Núi non hùng vĩ',
      'Hoa mùa xuân',
      'Bình minh trên đồi',
      'Đại dương bao la',
      'Khu vườn yên bình',
      'Bầu trời đầy sao',
    ];

    final randomTitle = titles[DateTime.now().second % titles.length];

    await _repository.saveGeneratedImage(randomTitle);
    _loadImages();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm ảnh mới!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _deleteImage(ImageItem image) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ảnh'),
        content: Text('Xóa ảnh "${image.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _repository.deleteImage(image.id!);
      _loadImages();
    }
  }

  void _showImageDetail(ImageItem image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 64),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    image.title ?? 'Không có tiêu đề',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    image.createdAt != null
                        ? '${image.createdAt!.day}/${image.createdAt!.month}/${image.createdAt!.year}'
                        : '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery ảnh'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildGallery()),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'MSSV: 6451071018',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addImage,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildGallery() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có ảnh nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn + để thêm ảnh mới',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        return _buildImageCard(image);
      },
    );
  }

  Widget _buildImageCard(ImageItem image) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () => _showImageDetail(image),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(image.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Text(
                  image.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                onPressed: () => _deleteImage(image),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.7),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
