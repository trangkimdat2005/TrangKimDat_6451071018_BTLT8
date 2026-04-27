import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/category.dart';
import '../data/models/expense.dart';
import '../data/repository/category_repository.dart';
import '../data/repository/expense_repository.dart';

class Cau4ExpenseScreen extends StatefulWidget {
  const Cau4ExpenseScreen({super.key});

  @override
  State<Cau4ExpenseScreen> createState() => _Cau4ExpenseScreenState();
}

class _Cau4ExpenseScreenState extends State<Cau4ExpenseScreen> {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  double _totalExpenses = 0;
  Map<String, double> _totalsByCategory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final expenses = await _expenseRepo.getAllExpenses();
    final categories = await _categoryRepo.getAllCategories();
    final total = await _expenseRepo.getTotalExpenses();
    final byCategory = await _expenseRepo.getTotalsByCategory();
    setState(() {
      _expenses = expenses;
      _categories = categories;
      _totalExpenses = total;
      _totalsByCategory = byCategory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => _showCategoryManager(),
            tooltip: 'Quản lý danh mục',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTotalCard(),
                _buildCategorySummary(),
                Expanded(child: _buildExpenseList()),
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
        onPressed: () => _navigateToAdd(),
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalCard() {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tổng chi tiêu',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(_totalExpenses),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_expenses.length} giao dịch',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySummary() {
    if (_totalsByCategory.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _totalsByCategory.length,
        itemBuilder: (context, index) {
          final entry = _totalsByCategory.entries.elementAt(index);
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.compact(locale: 'vi_VI').format(entry.value),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có chi tiêu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn + để thêm chi tiêu mới',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return _buildExpenseCard(expense);
      },
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEdit(expense),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt, color: Colors.red),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expense.categoryName ?? 'Không có danh mục',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(expense.amount),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(expense.id!),
                    child: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          categories: _categories,
          expense: null,
        ),
      ),
    );
    if (result == true) _loadData();
  }

  void _navigateToEdit(Expense expense) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseFormScreen(
          categories: _categories,
          expense: expense,
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
        content: const Text('Bạn có chắc muốn xóa chi tiêu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _expenseRepo.deleteExpense(id);
              _loadData();
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCategoryManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryManagerScreen(
          categories: _categories,
          categoryRepo: _categoryRepo,
        ),
      ),
    );
    _loadData();
  }
}

// Category Manager Screen
class CategoryManagerScreen extends StatefulWidget {
  final List<Category> categories;
  final CategoryRepository categoryRepo;

  const CategoryManagerScreen({
    super.key,
    required this.categories,
    required this.categoryRepo,
  });

  @override
  State<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends State<CategoryManagerScreen> {
  late List<Category> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục'),
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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await widget.categoryRepo.insertCategory(Category(name: result));
      _categories.add(Category(name: result));
      setState(() {});
    }
  }

  Future<void> _deleteCategory(Category category) async {
    await widget.categoryRepo.deleteCategory(category.id!);
    _categories.removeWhere((c) => c.id == category.id);
    setState(() {});
  }

  Future<void> _showEditDialog(Category category) async {
    final controller = TextEditingController(text: category.name);
    final result = await showDialog<String>(
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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await widget.categoryRepo.updateCategory(category.copyWith(name: result));
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category.copyWith(name: result);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _showEditDialog(category),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.red,
                            child: Icon(Icons.category, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(category.name, style: const TextStyle(fontSize: 16))),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _showDeleteDialog(category),
                          ),
                        ],
                      ),
                    ),
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
        onPressed: _addCategory,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Expense Form Screen
class ExpenseFormScreen extends StatefulWidget {
  final List<Category> categories;
  final Expense? expense;

  const ExpenseFormScreen({
    super.key,
    required this.categories,
    this.expense,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Category? _selectedCategory;
  final ExpenseRepository _repo = ExpenseRepository();

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = widget.expense!.amount.toString();
      _noteController.text = widget.expense!.note;
      if (widget.expense!.categoryId != null) {
        _selectedCategory = widget.categories.firstWhere(
          (c) => c.id == widget.expense!.categoryId,
          orElse: () => widget.categories.first,
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.expense?.id,
      amount: double.parse(_amountController.text),
      note: _noteController.text.trim(),
      categoryId: _selectedCategory?.id,
      categoryName: _selectedCategory?.name,
    );

    if (isEditing) {
      await _repo.updateExpense(expense);
    } else {
      await _repo.insertExpense(expense);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa chi tiêu' : 'Thêm chi tiêu'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập ghi chú';
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
                items: widget.categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEditing ? 'Cập nhật' : 'Lưu'),
              ),
              const SizedBox(height: 16),
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
