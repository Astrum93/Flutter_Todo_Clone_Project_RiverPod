import 'package:fast_app_base/data/memory/todo_status.dart';
import 'package:fast_app_base/data/memory/vo_todo.dart';
import 'package:fast_app_base/screen/dialog/d_confirm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screen/main/write/d_write_todo.dart';

/// 로그인이 되었을 때 유저 정보의 유무에 따라 다르게 보여주는 Provider
final userProvider = FutureProvider((ref) => 'User ID');

/// RiverPod에서는 상태 관리하는 객체를 만들 때 전역 변수로 만듬
final todoDataProvider =
    StateNotifierProvider<TodoDataHolder, List<Todo>>((ref) {
  /// Todo Data를 받아 올 때 User ID를 watch를 하면서 가져오는 코드
  final userID = ref.watch(userProvider);
  debugPrint(userID.value!);
  return TodoDataHolder();
});

class TodoDataHolder extends StateNotifier<List<Todo>> {
  TodoDataHolder() : super([]);

  void changeTodoStatus(Todo todo) async {
    switch (todo.status) {
      case TodoStatus.incomplete:
        todo.status = TodoStatus.ongoing;
      case TodoStatus.ongoing:
        todo.status = TodoStatus.complete;
      case TodoStatus.complete:
        final result = await ConfirmDialog('정말로 처음 상태로 변경 하시겠어요?').show();
        result?.runIfSuccess((data) {
          todo.status = TodoStatus.incomplete;
        });
        todo.status = TodoStatus.incomplete;
    }

    /// GetX의 refresh()와 동일
    state = List.of(state);
  }

  void addTodo() async {
    final result = await WriteTodoDialog().show();
    if (result != null) {
      state.add(Todo(
        id: DateTime.now().microsecondsSinceEpoch,
        title: result.text,
        dueDate: result.dateTime,
      ));

      /// GetX의 refresh()와 동일
      state = List.of(state);
    }
  }

  void editTodo(Todo todo) async {
    final result = await WriteTodoDialog(todoForEdit: todo).show();
    if (result != null) {
      todo.title = result.text;
      todo.dueDate = result.dateTime;

      /// GetX의 refresh()와 동일
      state = List.of(state);
    }
  }

  void removeTodo(Todo todo) {
    state.remove(todo);

    /// GetX의 refresh()와 동일
    state = List.of(state);
  }
}

extension TodoListHolderProvider on WidgetRef {
  TodoDataHolder get readTodoHolder => read(todoDataProvider.notifier);
}
