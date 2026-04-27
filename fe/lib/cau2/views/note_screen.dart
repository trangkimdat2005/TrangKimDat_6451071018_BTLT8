import 'package:flutter/material.dart';
import '../data/models/category.dart';
import '../data/models/note.dart';
import '../data/repository/category_repository.dart';
import '../data/repository/note_repository.dart';
import 'category_screen.dart';

class Cau2NoteListScreen extends StatefulWidget {
  const Cau2NoteListScreen({super.key});

  @override
  State<Cau2NoteListScreen> createState() => _Cau2NoteListScreenState();
}

class _Cau2NoteListScreenState extends State<Cau2NoteListScreen> {
  final NoteRepository _noteRepository = NoteRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  List<Note> _notes = [];
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await _categoryRepository.getAllCategories();
    final notes = await _noteRepository.getNotesByCategory(_selectedCategory?.id);
    setState(() {
      _categories = categories;
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _filterByCategory(Category? category) async {
    setState(() => _selectedCategory = category);
    _loadData();
  }

  Future<void> _deleteNote(int id) async {
    await _noteRepository.deleteNote(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi chú theo danh mục'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryListScreen(),
                ),
              );
              _loadData();
            },
            tooltip: 'Quản lý danh mục',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildNoteList()),
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
        onPressed: _navigateToAdd,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Tất cả'),
              selected: _selectedCategory == null,
              onSelected: (_) => _filterByCategory(null),
              selectedColor: Colors.teal.withValues(alpha: 0.2),
              checkmarkColor: Colors.teal,
            ),
            const SizedBox(width: 8),
            ..._categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: _selectedCategory?.id == cat.id,
                    onSelected: (_) => _filterByCategory(cat),
                    selectedColor: Colors.teal.withValues(alpha: 0.2),
                    checkmarkColor: Colors.teal,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có ghi chú nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    note.categoryName ?? 'Không có danh mục',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(note.id!),
            ),
            onTap: () => _navigateToDetail(note),
          ),
        );
      },
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cau2NoteDetailScreen(categories: _categories),
      ),
    );
    if (result == true) _loadData();
  }

  void _navigateToDetail(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cau2NoteDetailScreen(
          note: note,
          categories: _categories,
        ),
      ),
    );
    if (result == true) _loadData();
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class Cau2NoteDetailScreen extends StatefulWidget {
  final Note? note;
  final List<Category> categories;

  const Cau2NoteDetailScreen({
    super.key,
    this.note,
    required this.categories,
  });

  @override
  State<Cau2NoteDetailScreen> createState() => _Cau2NoteDetailScreenState();
}

class _Cau2NoteDetailScreenState extends State<Cau2NoteDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Category? _selectedCategory;
  final NoteRepository _repository = NoteRepository();

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    if (widget.note?.categoryId != null) {
      _selectedCategory = widget.categories.firstWhere(
        (c) => c.id == widget.note!.categoryId,
        orElse: () => widget.categories.first,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      categoryId: _selectedCategory?.id,
      categoryName: _selectedCategory?.name,
    );

    if (isEditing) {
      await _repository.updateNote(note);
    } else {
      await _repository.insertNote(note);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa ghi chú' : 'Tạo ghi chú mới'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<Category>(
                    value: null,
                    child: Text('Không có danh mục'),
                  ),
                  ...widget.categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.name),
                      )),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEditing ? 'Cập nhật' : 'Lưu'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MSSV: 6451071018',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
