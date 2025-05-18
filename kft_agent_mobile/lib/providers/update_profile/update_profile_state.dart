part of 'update_profile_bloc.dart';

abstract class UpdateProfileState extends Equatable {
  const UpdateProfileState();

  @override
  List<Object> get props => [];
}

class UpdateProfileInitial extends UpdateProfileState {}

class UpdateProfileLoading extends UpdateProfileState {}

class UpdateProfileSuccess extends UpdateProfileState {
  const UpdateProfileSuccess();

  @override
  List<Object> get props => [];
}

class UpdateProfileFailure extends UpdateProfileState {
  final String error;

  const UpdateProfileFailure({required this.error});

  @override
  List<Object> get props => [error];
}
