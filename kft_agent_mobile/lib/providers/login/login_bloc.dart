import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthDataProvider authDataProvider;

  LoginBloc({required this.authDataProvider}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final loginData = await authDataProvider.loginUser(
        email: event.email,
        password: event.password,
      );
      dpLocator<AuthLocalDataSource>().saveAuthData(
        userProfile: UserModel.fromJson(loginData["user"]),
        token: loginData['access'],
      );
      emit(LoginSuccess(loginData: loginData));
    } catch (e) {
      emit(LoginFailure(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
