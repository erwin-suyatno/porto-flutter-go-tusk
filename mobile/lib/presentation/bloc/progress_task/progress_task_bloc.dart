
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/source/task_source.dart';

part 'progress_task_event.dart';
part 'progress_task_state.dart';

class ProgressTaskBloc extends Bloc<ProgressTaskEvent, ProgressTaskState> {
  ProgressTaskBloc() : super(ProgressTaskInitial()) {
    on<OnFetchProgressTasks>((event, emit) async{
      emit(ProgressTaskLoading());
      List<Task>? tasks = await TaskSource.progressTask(event.userId);
      if (tasks == null) {
        emit(ProgressTaskFailed("Something went wrong"));
      } else {
        emit(ProgressTaskLoaded(tasks));
      }
    });
  }
}
