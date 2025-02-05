import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../constants/colors.dart';

class ToDoItem extends StatelessWidget {
  final ToDo todo;
  final Function(ToDo) onToDoChanged; // Callback for toggling task completion
  final Function(String) onDeleteItem; // Callback for deleting a task

  const ToDoItem({
    super.key,
    required this.todo,
    required this.onToDoChanged,
    required this.onDeleteItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          onToDoChanged(todo);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(
          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
          color: tdBlue,
        ),
        title: Text(
          todo.todoText!,
          style: TextStyle(
            fontSize: 18,
            color: tdBlack,
            fontWeight: FontWeight.w600,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          '${todo.priority} - ${todo.category}',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: GestureDetector(
          onTap: () {
            onDeleteItem(todo.id!);
          },
          child: Container(
            padding: const EdgeInsets.all(0),
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              color: tdRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}