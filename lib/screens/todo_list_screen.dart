import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/category.dart'; 
import '../database/database_helper.dart';
import 'todo_form_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  // State Variabel Search & Filter (Soal 4 & Soal 5)
  String _searchKeyword = '';
  bool? _filterStatus;
  int? _selectedCategoryId; 

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTodos();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getAllCategories();
    setState(() {
      _categories = categories;
    });
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);

    // Memuat data dengan filter keyword, status, dan categoryId (Soal 4 & 5)
    final todos = await _dbHelper.getFilteredTodos(
      keyword: _searchKeyword,
      isDone: _filterStatus,
      categoryId: _selectedCategoryId,
    );

    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  Future<void> _toggleTodo(Todo todo) async {
    await _dbHelper.toggleTodoStatus(todo.id!, !todo.isDone);
    _loadTodos();
  }

  Future<void> _deleteTodo(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Tugas ini akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteTodo(id);
      _loadTodos();
    }
  }

  Future<void> _navigateToAddForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TodoFormScreen()),
    );
    _loadTodos();
    _loadCategories(); 
  }

  Future<void> _navigateToEditForm(Todo todo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoFormScreen(todo: todo)),
    );
    _loadTodos();
    _loadCategories();
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Hapus semua yang selesai',
            onPressed: () async {
              await _dbHelper.clearCompletedTodos();
              _loadTodos();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Bagian Pencarian (Search)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onChanged: (value) {
                _searchKeyword = value;
                _loadTodos();
              },
            ),
          ),

          // 2. Bagian Filter Berdasarkan Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _filterStatus == null,
                  onSelected: (selected) {
                    setState(() => _filterStatus = null);
                    _loadTodos();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Belum Selesai'),
                  selected: _filterStatus == false,
                  onSelected: (selected) {
                    setState(() => _filterStatus = false);
                    _loadTodos();
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Selesai'),
                  selected: _filterStatus == true,
                  onSelected: (selected) {
                    setState(() => _filterStatus = true);
                    _loadTodos();
                  },
                ),
              ],
            ),
          ),

          // 3. Bagian Filter Berdasarkan Kategori (Soal 5)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              children: [
                const Text(
                  'Kategori: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ChoiceChip(
                  label: const Text('Semua Kategori'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategoryId = null);
                    _loadTodos();
                  },
                ),
                const SizedBox(width: 8),
                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                        _loadTodos();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(),

          // 4. Bagian Daftar Tugas (ListView)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _todos.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada tugas yang ditemukan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      final todo = _todos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isDone,
                            onChanged: (_) => _toggleTodo(todo),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: todo.isDone ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (todo.description.isNotEmpty)
                                Text(todo.description),
                              const SizedBox(height: 4),

                              // Menampilkan Nama Kategori (Soal 5)
                              if (todo.categoryId != null)
                                FutureBuilder<Category?>(
                                  future: _dbHelper.getCategoryById(todo.categoryId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 4.0),
                                        child: Text(
                                          'Kategori: ${snapshot.data!.name}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

                              // Menampilkan Batas Waktu jika ada
                              if (todo.deadline != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    'Batas Waktu: ${_formatDate(todo.deadline!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                              Text(
                                'Dibuat: ${_formatDate(todo.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine:
                              todo.description.isNotEmpty ||
                              todo.deadline != null ||
                              todo.categoryId != null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _navigateToEditForm(todo),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteTodo(todo.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}