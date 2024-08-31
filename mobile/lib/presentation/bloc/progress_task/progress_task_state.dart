part of 'progress_task_bloc.dart';

@immutable
sealed class ProgressTaskState {}

final class ProgressTaskInitial extends ProgressTaskState {}
final class ProgressTaskLoading extends ProgressTaskState {}
final class ProgressTaskFailed extends ProgressTaskState {
  final String message;

  ProgressTaskFailed(this.message);
}
final class ProgressTaskLoaded extends ProgressTaskState {
  final List<Task> tasks;

  ProgressTaskLoaded(this.tasks);
}
