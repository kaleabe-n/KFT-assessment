import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_consumer_mobile/lib.dart';

part 'update_profile_event.dart';
part 'update_profile_state.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final AuthDataProvider authDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  UpdateProfileBloc({
    required this.authDataProvider,
    required this.authLocalDataSource,
  }) : super(UpdateProfileInitial()) {
    on<UpdateProfileSubmitted>(_onUpdateProfileSubmitted);
  }

  Future<void> _onUpdateProfileSubmitted(
    UpdateProfileSubmitted event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(UpdateProfileLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      await authDataProvider.updateUserProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        authToken: authToken,
      );
      emit(const UpdateProfileSuccess());
    } catch (e) {
      emit(UpdateProfileFailure(
          error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
