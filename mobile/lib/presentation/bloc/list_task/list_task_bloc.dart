import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/source/task_source.dart';

part 'list_task_event.dart';
part 'list_task_state.dart';

class ListTaskBloc extends Bloc<ListTaskEvent, ListTaskState> {
  ListTaskBloc() : super(ListTaskInitial()) {
    on<OnFetchListTask>((event, emit) async{
      emit(ListTaskLoading());
      List<Task>? result = await TaskSource.whereUserAndStatus(
        event.employeeId, 
        event.status,
      );
      if (result == null) {
        emit(ListTaskFailed('Failed to fetch data'));
      } else {
        emit(ListTaskLoaded(result));
      }
    });
  }
}
