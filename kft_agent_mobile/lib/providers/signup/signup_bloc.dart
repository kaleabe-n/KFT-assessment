import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthDataProvider authDataProvider;

  SignUpBloc({required this.authDataProvider}) : super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());
    try {
      final String emailForResult = await authDataProvider.initiateSignUp(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        roleType: event.roleType,
      );
      emit(SignUpSuccess(email: emailForResult));
    } catch (e) {
      emit(SignUpFailure(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
