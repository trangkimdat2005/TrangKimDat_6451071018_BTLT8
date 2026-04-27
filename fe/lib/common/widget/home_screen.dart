import 'package:flutter/material.dart';
import '../../cau1/views/note_screen.dart';
import '../../cau2/views/note_screen.dart';
import '../../cau3/views/task_screen.dart';
import '../../cau4/views/expense_screen.dart';
import '../../cau5/views/dictionary_screen.dart';
import '../../cau6/views/gallery_screen.dart';
import '../../cau7/views/student_course_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BTLT Flutter'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danh sách bài tập',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trang Kim Đạt - 6451071018',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCard(
                        context,
                        number: '01',
                        title: 'Ứng dụng Ghi chú cơ bản',
                        subtitle: 'SQLite CRUD - Tạo, xem, sửa, xóa ghi chú',
                        icon: Icons.sticky_note_2,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NoteListScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '02',
                        title: 'Ghi chú có danh mục',
                        subtitle: 'SQLite có khóa ngoại - Lọc theo danh mục',
                        icon: Icons.category,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cau2NoteListScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '03',
                        title: 'To-do List',
                        subtitle: 'SQLite + JSON Backup - Export/Import',
                        icon: Icons.checklist,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cau3TaskScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '04',
                        title: 'Quản lý chi tiêu',
                        subtitle: 'SQLite nhiều bảng - Tính tổng theo danh mục',
                        icon: Icons.account_balance_wallet,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cau4ExpenseScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '05',
                        title: 'Từ điển offline',
                        subtitle: 'JSON + SQLite - Tra cứu từ điển',
                        icon: Icons.menu_book,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cau5DictionaryScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '06',
                        title: 'Lưu ảnh offline',
                        subtitle: 'File + SQLite - Gallery ảnh',
                        icon: Icons.photo_library,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cau6GalleryScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '07',
                        title: 'Quản lý SV - Môn học',
                        subtitle: 'Quan hệ nhiều-nhiều - Đăng ký môn',
                        icon: Icons.school,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Cau7StudentCourseScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        number: '08',
                        title: 'Câu 8',
                        subtitle: 'Chưa có nội dung',
                        icon: Icons.pending,
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildCard(
                        context,
                        number: '09',
                        title: 'Câu 9',
                        subtitle: 'Chưa có nội dung',
                        icon: Icons.pending,
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildCard(
                        context,
                        number: '10',
                        title: 'Câu 10',
                        subtitle: 'Chưa có nội dung',
                        icon: Icons.pending,
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: const Color(0xFF667eea)),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng đang được phát triển!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
