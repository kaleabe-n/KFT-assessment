part of 'signup_bloc.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String email;

  const SignUpSuccess({required this.email});

  @override
  List<Object> get props => [email];
}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure({required this.error});

  @override
  List<Object> get props => [error];
}
