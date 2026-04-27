import 'package:flutter/material.dart';
import '../data/models/category.dart';
import '../data/repository/category_repository.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryRepository _repository = CategoryRepository();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await _repository.getAllCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _deleteCategory(int id) async {
    await _repository.deleteCategory(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _categories.isEmpty
                      ? const Center(
                          child: Text(
                            'Chưa có danh mục nào.\nNhấn + để tạo danh mục mới.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Icon(Icons.folder, color: Colors.white),
                                ),
                                title: Text(category.name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(category.id!),
                                ),
                                onTap: () => _showEditDialog(category),
                              ),
                            );
                          },
                        ),
                ),
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
        onPressed: _showAddDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục mới'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _repository.insertCategory(
                  Category(name: controller.text.trim()),
                );
                Navigator.pop(context);
                _loadCategories();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Category category) {
    final controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa danh mục'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _repository.updateCategory(
                  category.copyWith(name: controller.text.trim()),
                );
                Navigator.pop(context);
                _loadCategories();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa danh mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
