part of 'list_task_bloc.dart';

@immutable
sealed class ListTaskState {}

final class ListTaskInitial extends ListTaskState {}
final class ListTaskLoading extends ListTaskState {}
final class ListTaskFailed extends ListTaskState {
  final String message;

  ListTaskFailed(this.message);
}
final class ListTaskLoaded extends ListTaskState {
  final List<Task> tasks;

  ListTaskLoaded(this.tasks);
}
