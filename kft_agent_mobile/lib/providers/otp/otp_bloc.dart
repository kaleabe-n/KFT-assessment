import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kft_agent_mobile/lib.dart';

part 'otp_event.dart';
part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final AuthDataProvider authDataProvider;

  OtpBloc({required this.authDataProvider}) : super(OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(OtpLoading());
    try {
      await authDataProvider.verifyOtp(
        email: event.email,
        otpCode: event.otpCode,
      );
      emit(const OtpSuccess());
    } catch (e) {
      emit(OtpFailure(error: e.toString().replaceFirst("Exception: ", "")));
    }
  }
}
