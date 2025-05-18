part of 'otp_bloc.dart';

abstract class OtpState extends Equatable {
  const OtpState();

  @override
  List<Object> get props => [];
}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpSuccess extends OtpState {
  const OtpSuccess();

  @override
  List<Object> get props => [];
}

class OtpFailure extends OtpState {
  final String error;

  const OtpFailure({required this.error});

  @override
  List<Object> get props => [error];
}
