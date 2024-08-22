

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/data/models/task.dart';

class TaskCubit extends Cubit<Task> {
  TaskCubit() : super(Task());

  update(Task n) => emit(n);
}
