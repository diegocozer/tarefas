import 'package:flutter/material.dart';
import 'package:tarefas/models/todo.dart';
import 'package:tarefas/repositories/todo_repositorie.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todosController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;
  String? erroText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 7,
        child: SafeArea(
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: todosController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Adicione uma tarefa',
                              hintText: 'Ex. Estudar Flutter',
                              errorText: erroText,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff00d7f3),
                                  width: 2,
                                ),
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            String text = todosController.text;
                            if (text.isEmpty) {
                              setState(() {
                                erroText = 'O titulo não pode estar vazio!';
                              });
                              return;
                            }
                            setState(
                              () {
                                Todo newTodo =
                                    Todo(title: text, dateTime: DateTime.now());
                                todos.add(newTodo);
                                todosController.clear();
                                todoRepository.saveTodoList(todos);
                                erroText = null;
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: const Color(0xff00d7f3),
                            padding: const EdgeInsets.all(19),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 30,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Flexible(
                      child: ListView(shrinkWrap: true, children: [
                        for (Todo todo in todos)
                          TodoListItem(
                            todo: todo,
                            onDelete: onDelete,
                          ),
                      ]),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                              'Você possui ${todos.length} tarefas pendentes'),
                        ),
                        ElevatedButton(
                          onPressed: showDeleteTodoConfirmationDialog,
                          child: const Text('Limpar tudo'),
                          style: ElevatedButton.styleFrom(
                            primary: const Color(0xff00d7f3),
                            padding: const EdgeInsets.all(19),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);
    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: const TextStyle(
            color: Color(0Xff060708),
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xff00d7f3),
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeleteTodoConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Tudo?'),
        content:
            const Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              primary: const Color(0xff00d7f3),
            ),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
            child: const Text('Limpar Tudo'),
          )
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
