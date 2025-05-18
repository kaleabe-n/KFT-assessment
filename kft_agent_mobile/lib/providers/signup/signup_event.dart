part of 'signup_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpSubmitted extends SignUpEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String roleType;

  const SignUpSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.roleType = "agent",
  });

  @override
  List<Object> get props => [firstName, lastName, email, password, roleType];
}
