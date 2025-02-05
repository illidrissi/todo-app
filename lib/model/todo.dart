class ToDo {
  String? id;
  String? todoText;
  String? priority;
  String? category;
  DateTime? dueDate; // Optional due date
  String? notes; // Add this property
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.priority = 'Low',
    this.category = 'Work',
    this.dueDate, // Nullable due date
    this.notes, // Nullable notes
    this.isDone = false,
  });

  // Factory method to create a ToDo object from JSON
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      priority: json['priority'],
      category: json['category'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      notes: json['notes'], // Deserialize notes
      isDone: json['isDone'] ?? false,
    );
  }

  // Method to convert ToDo object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'priority': priority,
      'category': category,
      'dueDate': dueDate?.toIso8601String(), // Convert DateTime to string
      'notes': notes, // Serialize notes
      'isDone': isDone,
    };
  }

  // Static method to provide a default list of todos
  static List<ToDo> todoList() {
    return [
      ToDo(
        id: '1',
        todoText: 'Buy groceries',
        priority: 'Medium',
        category: 'Personal',
        dueDate: DateTime.now().add(const Duration(days: 2)), // Example due date
        notes: 'Remember to buy milk and bread', // Example notes
      ),
      ToDo(
        id: '2',
        todoText: 'Complete project',
        priority: 'High',
        category: 'Work',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        notes: 'Submit by EOD',
      ),
      ToDo(
        id: '3',
        todoText: 'Call mom',
        priority: 'Low',
        category: 'Personal',
        notes: 'Ask about her day',
      ),
    ];
  }
}