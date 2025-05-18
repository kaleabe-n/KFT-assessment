import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthDataProvider authDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  ChangePasswordBloc({
    required this.authDataProvider,
    required this.authLocalDataSource,
  }) : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onChangePasswordSubmitted);
  }

  Future<void> _onChangePasswordSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      await authDataProvider.changePassword(
        oldPassword: event.oldPassword,
        newPassword1: event.newPassword1,
        newPassword2: event.newPassword2,
        authToken: authToken,
      );
      emit(ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordFailure(
          error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
