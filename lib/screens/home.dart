import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import '../model/todo.dart';
import '../widgets/todo_item.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/colors.dart';

class Home extends StatefulWidget {
  final SharedPreferences prefs;
  const Home({super.key, required this.prefs});

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ToDo> todosList = ToDo.todoList();
  List<ToDo> _foundToDo = [];
  final TextEditingController _todoController = TextEditingController();
  bool isDarkMode = false;

  // Notifications plugin
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _foundToDo = List.from(todosList);
    _loadTodosFromPrefs();
    _loadThemePreference();
    _initializeNotifications();
  }

  // Modify your _initializeNotifications method
  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones(); // Add this line
    
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitSettings);

    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadTodosFromPrefs() async {
    List<String>? storedTodos = widget.prefs.getStringList('todos');
    if (storedTodos != null) {
      setState(() {
        todosList = storedTodos.map((json) => ToDo.fromJson(jsonDecode(json))).toList();
        _foundToDo = List.from(todosList);
      });
    } else {
      todosList = ToDo.todoList();
      saveTodosToPrefs();
    }
  }

  Future<void> saveTodosToPrefs() async {
    List<String> todoJsonList =
        todosList.map((todo) => jsonEncode(todo.toJson())).toList();
    await widget.prefs.setStringList('todos', todoJsonList);
  }

  Future<void> _loadThemePreference() async {
    isDarkMode = widget.prefs.getBool('isDarkMode') ?? false;
    setState(() {});
  }

  Future<void> _saveThemePreference(bool value) async {
    widget.prefs.setBool('isDarkMode', value);
    setState(() => isDarkMode = value);
  }

  void _handleToDoChange(ToDo todo) {
    setState(() => todo.isDone = !todo.isDone);
    saveTodosToPrefs();
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
      _foundToDo.removeWhere((item) => item.id == id);
    });
    saveTodosToPrefs();
  }

  void _addToDoItem(
      String toDo, String priority, String category, DateTime? dueDate, String notes) {
    if (toDo.trim().isEmpty) return;
    final newTodo = ToDo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      todoText: toDo,
      priority: priority,
      category: category,
      dueDate: dueDate,
      notes: notes,
    );
    setState(() {
      todosList.add(newTodo);
      _foundToDo.add(newTodo);
    });
    _todoController.clear();
    saveTodosToPrefs();
    _scheduleNotification(newTodo);
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      _foundToDo = enteredKeyword.isEmpty
          ? List.from(todosList)
          : todosList
              .where((item) => item.todoText!
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
              .toList();
    });
  }

  Widget _buildDashboard() {
    int totalTasks = todosList.length;
    int completedTasks = todosList.where((task) => task.isDone).length;
    double completionPercentage = (completedTasks / totalTasks) * 100;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Tasks: $totalTasks',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          Text(
            'Completed Tasks: $completedTasks',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
          LinearProgressIndicator(
            value: totalTasks > 0 ? completionPercentage / 100 : 0,
            backgroundColor: isDarkMode ? secondaryDark : secondaryLight,
            valueColor: const AlwaysStoppedAnimation<Color>(primaryDark),
          ),
          const SizedBox(height: 10),
          Text(
            '${completionPercentage.toStringAsFixed(1)}% Completed',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: _runFilter,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.blue, size: 25),
          border: InputBorder.none,
          hintText: 'Search tasks...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
        ),
        style: GoogleFonts.poppins(color: Colors.black87),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: _todoController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Add new task...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              onPressed: () => _showAddTaskDialog(),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    String? selectedPriority = 'Low'; // Default priority
    String? selectedCategory = 'Work'; // Default category
    DateTime? dueDate;
    String notes = '';

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoController,
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  hintStyle: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedPriority,
                items: ['Low', 'Medium', 'High']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedPriority = value),
                decoration: InputDecoration(
                  labelText: 'Priority',
                  labelStyle: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedCategory,
                items: ['Work', 'Personal', 'Shopping']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.poppins(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );
                  setState(() => dueDate = pickedDate);
                },
                child: Text('Set Due Date'),
              ),
              TextField(
                onChanged: (value) => notes = value,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: GoogleFonts.poppins(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.poppins()),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addToDoItem(
                        _todoController.text,
                        selectedPriority!,
                        selectedCategory!,
                        dueDate,
                        notes,
                      );
                      Navigator.pop(context);
                    },
                    child: Text('Add', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scheduleNotification(ToDo todo) async {
    if (todo.dueDate != null) {
      final scheduledDate = tz.TZDateTime.from(todo.dueDate!, tz.local);
      
      // Only schedule if date is in the future
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      try {
        await notificationsPlugin.zonedSchedule(
          int.parse(todo.id!),
          'Task Reminder',
          todo.todoText!,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_channel',
              'Task Channel',
              channelDescription: 'Notifications for task reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? primaryDark : primaryLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? secondaryDark : secondaryLight,
        elevation: 0,
        toolbarHeight: 80,
        title: Text(
          'Welcome Back!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? primaryDark : primaryLight,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDarkMode ? primaryLight : primaryDark,
            size: 32,
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDarkMode ? primaryLight : primaryDark,
              size: 32,
            ),
            onPressed: () {
              _saveThemePreference(!isDarkMode);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDashboard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: _searchBox(),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _foundToDo.length,
              itemBuilder: (context, index) {
                final todo = _foundToDo[index];
                return ToDoItem(
                  todo: todo,
                  onToDoChanged: _handleToDoChange,
                  onDeleteItem: _deleteToDoItem,
                );
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }
}