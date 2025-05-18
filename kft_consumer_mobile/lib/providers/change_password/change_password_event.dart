part of 'change_password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword1;
  final String newPassword2;

  const ChangePasswordSubmitted({
    required this.oldPassword,
    required this.newPassword1,
    required this.newPassword2,
  });

  @override
  List<Object> get props => [oldPassword, newPassword1, newPassword2];
}
