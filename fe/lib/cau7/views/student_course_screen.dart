import 'package:flutter/material.dart';
import '../data/models/student.dart';
import '../data/models/course.dart';
import '../data/repository/student_repository.dart';
import '../data/repository/course_repository.dart';
import '../data/repository/enrollment_repository.dart';

class Cau7StudentCourseScreen extends StatefulWidget {
  const Cau7StudentCourseScreen({super.key});

  @override
  State<Cau7StudentCourseScreen> createState() =>
      _Cau7StudentCourseScreenState();
}

class _Cau7StudentCourseScreenState extends State<Cau7StudentCourseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_StudentTabState> _studentTabKey = GlobalKey();
  final GlobalKey<_CourseTabState> _courseTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _refreshTabs() {
    _studentTabKey.currentState?._loadStudents();
    _courseTabKey.currentState?._loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý SV - Môn học'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Sinh viên'),
            Tab(icon: Icon(Icons.book), text: 'Môn học'),
            Tab(icon: Icon(Icons.school), text: 'Đăng ký'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StudentTab(key: _studentTabKey),
          _CourseTab(key: _courseTabKey),
          const _EnrollmentTab(),
        ],
      ),
      floatingActionButton: _tabController.index < 2
          ? FloatingActionButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  _studentTabKey.currentState?.showAddDialog();
                  _refreshTabs();
                } else if (_tabController.index == 1) {
                  _courseTabKey.currentState?.showAddDialog();
                  _refreshTabs();
                }
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _StudentTab extends StatefulWidget {
  const _StudentTab({super.key});

  @override
  State<_StudentTab> createState() => _StudentTabState();
}

class _StudentTabState extends State<_StudentTab> {
  final StudentRepository _repository = StudentRepository();
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final students = await _repository.getAllStudents();
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  Future<void> showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm sinh viên'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên sinh viên',
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
      await _repository.insertStudent(Student(name: result));
      _loadStudents();
    }
  }

  Future<void> _editStudent(Student student) async {
    final controller = TextEditingController(text: student.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa sinh viên'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên sinh viên',
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
      await _repository.updateStudent(student.copyWith(name: result));
      _loadStudents();
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sinh viên'),
        content: Text('Xóa sinh viên "${student.name}"?'),
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
      await _repository.deleteStudent(student.id!);
      _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có sinh viên nào',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(student.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editStudent(student),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStudent(student),
                            ),
                          ],
                        ),
                        onTap: () => _editStudent(student),
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
    );
  }
}

class _CourseTab extends StatefulWidget {
  const _CourseTab({super.key});

  @override
  State<_CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<_CourseTab> {
  final CourseRepository _repository = CourseRepository();
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await _repository.getAllCourses();
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  Future<void> showAddDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm môn học'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên môn học',
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
      await _repository.insertCourse(Course(name: result));
      _loadCourses();
    }
  }

  Future<void> _editCourse(Course course) async {
    final controller = TextEditingController(text: course.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa môn học'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên môn học',
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
      await _repository.updateCourse(course.copyWith(name: result));
      _loadCourses();
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa môn học'),
        content: Text('Xóa môn học "${course.name}"?'),
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
      await _repository.deleteCourse(course.id!);
      _loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có môn học nào',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                          child: const Icon(Icons.book, color: Colors.green),
                        ),
                        title: Text(course.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCourse(course),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCourse(course),
                            ),
                          ],
                        ),
                        onTap: () => _editCourse(course),
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
    );
  }
}

class _EnrollmentTab extends StatefulWidget {
  const _EnrollmentTab();

  @override
  State<_EnrollmentTab> createState() => _EnrollmentTabState();
}

class _EnrollmentTabState extends State<_EnrollmentTab> {
  final StudentRepository _studentRepo = StudentRepository();
  final CourseRepository _courseRepo = CourseRepository();
  final EnrollmentRepository _enrollmentRepo = EnrollmentRepository();

  List<Student> _students = [];
  List<Course> _courses = [];
  Student? _selectedStudent;
  List<int> _enrolledCourseIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final students = await _studentRepo.getAllStudents();
    final courses = await _courseRepo.getAllCourses();
    setState(() {
      _students = students;
      _courses = courses;
      if (students.isNotEmpty && _selectedStudent == null) {
        _selectedStudent = students.first;
      }
      _isLoading = false;
    });
    if (_selectedStudent != null) {
      await _loadEnrollments();
    }
  }

  Future<void> _loadEnrollments() async {
    if (_selectedStudent == null) return;
    final enrolledIds = await _enrollmentRepo.getEnrolledCourseIds(
      _selectedStudent!.id!,
    );
    setState(() => _enrolledCourseIds = enrolledIds);
  }

  Future<void> _selectStudent(Student student) async {
    setState(() => _selectedStudent = student);
    await _loadEnrollments();
  }

  Future<void> _toggleCourse(Course course) async {
    if (_selectedStudent == null) return;
    await _enrollmentRepo.toggleEnrollment(_selectedStudent!.id!, course.id!);
    await _loadEnrollments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có sinh viên nào.\nHãy thêm sinh viên trước.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : _buildEnrollmentContent(),
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
    );
  }

  Widget _buildEnrollmentContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn sinh viên:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<Student>(
                  value: _selectedStudent,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _students.map((student) {
                    return DropdownMenuItem(
                      value: student,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            child: Text(
                              student.name.isNotEmpty
                                  ? student.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(student.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (student) {
                    if (student != null) _selectStudent(student);
                  },
                ),
              ),
            ],
          ),
        ),
        if (_courses.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có môn học nào.\nHãy thêm môn học trước.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                final isEnrolled = _enrolledCourseIds.contains(course.id);

                return Card(
                  child: CheckboxListTile(
                    value: isEnrolled,
                    onChanged: (_) => _toggleCourse(course),
                    activeColor: Colors.blue,
                    title: Text(course.name),
                    secondary: CircleAvatar(
                      backgroundColor: isEnrolled
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.book,
                        color: isEnrolled ? Colors.green : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      isEnrolled ? 'Đã đăng ký' : 'Chưa đăng ký',
                      style: TextStyle(
                        color: isEnrolled ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
