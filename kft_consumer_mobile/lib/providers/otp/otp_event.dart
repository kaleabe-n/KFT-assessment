part of 'otp_bloc.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object> get props => [];
}

class OtpSubmitted extends OtpEvent {
  final String email;
  final String otpCode;

  const OtpSubmitted({
    required this.email,
    required this.otpCode,
  });

  @override
  List<Object> get props => [email, otpCode];
}
