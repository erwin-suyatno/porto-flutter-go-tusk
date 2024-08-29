part of 'need_review_bloc.dart';

@immutable
sealed class NeedReviewEvent {}

class OnFetchNeedReview extends NeedReviewEvent {}