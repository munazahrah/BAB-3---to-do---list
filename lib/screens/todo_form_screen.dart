import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/category.dart';
import '../database/database_helper.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;
  const TodoFormScreen({super.key, this.todo});

  @override
  State<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isSaving = false;
  bool get _isEditMode => widget.todo != null;

  // --- KODE BARU UNTUK SOAL 5 (State Kategori) ---
  List<Category> _categories = [];
  int? _selectedCategoryId;

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getAllCategories();
    setState(() {
      _categories = categories;
      if (_isEditMode && widget.todo!.categoryId != null) {
        _selectedCategoryId = widget.todo!.categoryId;
      }
    });
  }
  // -----------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadCategories(); 
    if (_isEditMode) {
      _titleController.text = widget.todo!.title;
      _descController.text = widget.todo!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      if (_isEditMode) {
        // --- KODE LAMA DIKOMENTARI ---
        /*
        final updatedTodo = Todo(
          id: widget.todo!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          isDone: widget.todo!.isDone,
          createdAt: widget.todo!.createdAt,
        );
        */

        // --- KODE BARU UNTUK SOAL 5 ---
        final updatedTodo = Todo(
          id: widget.todo!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          isDone: widget.todo!.isDone,
          createdAt: widget.todo!.createdAt,
          deadline: widget.todo!.deadline,
          categoryId: _selectedCategoryId,
        );
        // ------------------------------
        await _dbHelper.updateTodo(updatedTodo);
      } else {
        // --- KODE LAMA DIKOMENTARI ---
        /*
        final newTodo = Todo(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          createdAt: DateTime.now().toIso8601String(),
        );
        */

        // --- KODE BARU UNTUK SOAL 5 ---
        final newTodo = Todo(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          createdAt: DateTime.now().toIso8601String(),
          categoryId: _selectedCategoryId, // Menyimpan kategori terpilih
        );
        // ------------------------------
        await _dbHelper.insertTodo(newTodo);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan tugas: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Tugas' : 'Tambah Tugas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  hintText: 'Masukkan judul tugas',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tugas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // --- KODE BARU UNTUK SOAL 5 (Dropdown Pilihan Kategori) ---
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Tanpa Kategori'),
                  ),
                  ..._categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // ----------------------------------------------------------

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  hintText: 'Masukkan deskripsi tugas',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTodo,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditMode ? 'Simpan Perubahan' : 'Tambah Tugas'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}