part of 'list_task_bloc.dart';

@immutable
sealed class ListTaskEvent {}


class OnFetchListTask extends ListTaskEvent {
  final int employeeId;
  final String status;

  OnFetchListTask(this.employeeId, this.status);
}
