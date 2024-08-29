
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/enums.dart';
import 'package:mobile/data/models/task.dart';
import 'package:mobile/data/source/task_source%20.dart';

part 'need_review_event.dart';
part 'need_review_state.dart';

class NeedReviewBloc extends Bloc<NeedReviewEvent, NeedReviewState> {
  NeedReviewBloc() : super(NeedReviewState.init()) {
    on<OnFetchNeedReview>((event, emit) async{
      emit(NeedReviewState(RequestStatus.loading, []));
      List<Task>? result = await TaskSource.needToBeReview();
      if (result == null) {
        emit(NeedReviewState(RequestStatus.failed, []));
      } else {
        emit(NeedReviewState(RequestStatus.success, result));
      }
    });
  }
}
