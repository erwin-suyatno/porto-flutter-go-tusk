import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/data/source/task_source%20.dart';

class StatEmployeeCubit extends Cubit<Map> {
  StatEmployeeCubit() : super(_init);
  static final Map _init = {
    "Queue": 0,
    "Review": 0,
    "Approved": 0,
    "Rejected": 0,
  };

  fetchStatistic(int userId) async{
    final result = await TaskSource.statisticTask(userId);
    if(result == null) {
      emit(_init);
    }else {
      emit(result!);
    }
  }
}
