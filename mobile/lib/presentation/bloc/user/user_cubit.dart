import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/data/models/user.dart';

class UserCubit extends Cubit<User> {
  UserCubit() : super(User());

  update(User n) => emit(n);
}
