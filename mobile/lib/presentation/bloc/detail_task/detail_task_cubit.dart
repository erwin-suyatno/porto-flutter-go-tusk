import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/enums.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/source/task_source.dart';

part 'detail_task_state.dart';

class DetailTaskCubit extends Cubit<DetailTaskState> {
  DetailTaskCubit() : super(DetailTaskState(null, RequestStatus.init));

  fetchDetailTask(int id) async{
    emit(DetailTaskState(null, RequestStatus.loading));

    final result = await TaskSource.findTaskById(id);
    if (result == null){
      emit(DetailTaskState(null, RequestStatus.failed));
    } else {
      emit(DetailTaskState(result, RequestStatus.success));
    }
  }
}
