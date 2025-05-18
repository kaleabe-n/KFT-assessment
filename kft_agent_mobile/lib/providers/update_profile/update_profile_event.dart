part of 'update_profile_bloc.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfileSubmitted extends UpdateProfileEvent {
  final String firstName;
  final String lastName;
  final String email;

  const UpdateProfileSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  @override
  List<Object> get props => [firstName, lastName, email];
}
