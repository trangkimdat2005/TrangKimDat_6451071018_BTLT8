import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/task.dart';
import '../data/repository/task_repository.dart';

class Cau3TaskScreen extends StatefulWidget {
  const Cau3TaskScreen({super.key});

  @override
  State<Cau3TaskScreen> createState() => _Cau3TaskScreenState();
}

class _Cau3TaskScreenState extends State<Cau3TaskScreen> {
  final TaskRepository _repository = TaskRepository();
  final TextEditingController _taskController = TextEditingController();
  List<Task> _tasks = [];
  bool _isLoading = true;
  List<FileSystemEntity> _backupFiles = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _repository.getAllTasks();
    final files = await _repository.getBackupFiles();
    setState(() {
      _tasks = tasks;
      _backupFiles = files;
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) return;

    final task = Task(title: _taskController.text.trim());
    await _repository.insertTask(task);
    _taskController.clear();
    _loadTasks();
  }

  Future<void> _toggleTask(Task task) async {
    final updatedTask = task.copyWith(isDone: !task.isDone);
    await _repository.updateTask(updatedTask);
    _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await _repository.deleteTask(id);
    _loadTasks();
  }

  Future<void> _exportToJson() async {
    try {
      final filePath = await _repository.exportToJson();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu backup: $filePath'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
        _loadTasks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi export: $e')),
        );
      }
    }
  }

  Future<void> _showImportDialog() async {
    await _loadTasks();

    if (_backupFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có file backup nào')),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn file backup'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _backupFiles.length,
            itemBuilder: (context, index) {
              final file = _backupFiles[index];
              final fileName = file.path.split('/').last;
              final dateStr = fileName
                  .replaceAll('tasks_backup_', '')
                  .replaceAll('.json', '')
                  .split('_')
                  .take(3)
                  .join('-');

              return ListTile(
                leading: const Icon(Icons.file_present),
                title: Text(dateStr),
                subtitle: Text(fileName),
                onTap: () async {
                  Navigator.pop(context);
                  await _importFromJson(file.path);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromJson(String filePath) async {
    try {
      final count = await _repository.importFromJson(filePath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã import $count task thành công')),
        );
        _loadTasks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi import: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do List'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _exportToJson,
            tooltip: 'Export JSON',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _showImportDialog,
            tooltip: 'Import JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAddTaskBar(),
          Expanded(child: _buildTaskList()),
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
    );
  }

  Widget _buildAddTaskBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Nhập công việc mới...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _addTask(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có công việc nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm công việc mới ở trên',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final pendingTasks = _tasks.where((t) => !t.isDone).toList();
    final completedTasks = _tasks.where((t) => t.isDone).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pendingTasks.isNotEmpty) ...[
          _buildSectionHeader('Cần làm', pendingTasks.length, Colors.orange),
          ...pendingTasks.map((task) => _buildTaskTile(task)),
        ],
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Đã hoàn thành', completedTasks.length, Colors.green),
          ...completedTasks.map((task) => _buildTaskTile(task)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$title ($count)',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: task.isDone,
        onChanged: (_) => _toggleTask(task),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : null,
          ),
        ),
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _showDeleteDialog(task.id!),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.green,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask(id);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
