import 'package:mobile/common/enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(null, RequestStatus.init));

  clickLogin(String email, String password) async {
    // final result = await UserSource.login(email, password);
    // if (result == null) {
    //   DInfo.toastError('Login Failed');
    //   emit(LoginState(null, RequestStatus.failed));
    // } else {
    //   DInfo.toastSuccess('Login Success');
    //   DSession.setUser(result.toJson());
    //   emit(LoginState(result, RequestStatus.success));
    // }
  }
}
