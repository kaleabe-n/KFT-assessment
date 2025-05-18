import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AgentDataProvider agentDataProvider;
  final AuthLocalDataSource authLocalDataSource;

  ProfileBloc({
    required this.agentDataProvider,
    required this.authLocalDataSource,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final authToken = await authLocalDataSource.getToken();
      if (authToken == null) {
        throw Exception("Authentication token not found. Please log in.");
      }

      final userProfile =
          await agentDataProvider.getUserProfile(authToken: authToken);
      emit(ProfileLoaded(userProfile: userProfile));
    } catch (e) {
      emit(ProfileError(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
