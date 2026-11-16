class Todo {
  final int? id;
  final String title;
  final String description;
  final String createdAt;
  final bool isDone;
  final String? deadline; 
  
  // --- KODE BARU UNTUK SOAL 5 ---
  final int? categoryId; 
  final String? categoryName; 
  // ------------------------------

  // --- KODE LAMA DIKOMENTARI ---
  /*
  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isDone = false,
    this.deadline,
  });
  */

  // --- KODE BARU ---
  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isDone = false,
    this.deadline,
    this.categoryId, // Tambahan Soal 5
    this.categoryName, // Tambahan Soal 5
  });

  Map<String, dynamic> toMap() {
    // --- KODE LAMA DIKOMENTARI ---
    /*
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'isDone': isDone ? 1 : 0,
      'deadline': deadline,
    };
    */

    // --- KODE BARU ---
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'isDone': isDone ? 1 : 0,
      'deadline': deadline,
      'categoryId': categoryId, // Tambahan Soal 5
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    // --- KODE LAMA DIKOMENTARI ---
    /*
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: map['createdAt'],
      isDone: map['isDone'] == 1,
      deadline: map['deadline'],
    );
    */

    // --- KODE BARU ---
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: map['createdAt'],
      isDone: map['isDone'] == 1,
      deadline: map['deadline'],
      categoryId: map['categoryId'], // Tambahan Soal 5
      categoryName: map['categoryName'], // Tambahan Soal 5 (Hasil JOIN)
    );
  }
}