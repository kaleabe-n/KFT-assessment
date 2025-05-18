import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:kft_consumer_mobile/lib.dart';

class AuthDataProvider {
  final Dio dio;
  final String _baseUrl = baseUrl;

  AuthDataProvider({required this.dio});

  Future<String> initiateSignUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String roleType,
  }) async {
    final response = await dio.post(
      '$_baseUrl/api/auth/users/',
      options: Options(headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-F',
      }),
      data: (<String, String>{
        'first_name': firstName,
        'last_name': lastName,
        'username': email,
        'email': email,
        'password': password,
        'role_type': roleType,
      }),
    );

    if (response.statusCode == 200) {
      return email;
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.data);
      String errorMessage = "Signup failed. Please check your input.";
      if (responseBody is Map && responseBody.isNotEmpty) {
        errorMessage = responseBody.entries
            .map((e) =>
                '${e.key}: ${e.value is List ? e.value.join(', ') : e.value}')
            .join('\n');
      }
      throw Exception(errorMessage);
    } else {
      throw Exception(
          'Failed to initiate sign up. Status code: ${response.statusCode}');
    }
  }

  Future<UserModel> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await dio.post(
      '$_baseUrl/api/auth/users/verify-otp/',
      options: Options(headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-F',
      }),
      data: (<String, String>{
        'email': email,
        'otp_code': otpCode,
      }),
    );

    if (response.statusCode == 201) {
      final responseBody = (response.data);
      dpLocator<AuthLocalDataSource>().saveAuthData(
          userProfile: UserModel.fromJson(responseBody['user']),
          token: responseBody['access']);
      return UserModel.fromJson(responseBody['user']);
    } else if (response.statusCode == 400) {
      final responseBody = (response.data);
      throw Exception(responseBody['error'] ??
          responseBody['message'] ??
          'OTP verification failed.');
    } else {
      throw Exception(
          'Failed to verify OTP. Status code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/auth/token/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-F',
        }),
        data: (<String, String>{
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['detail'] ??
                response.data?['error'] ??
                'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Login failed');
    }
  }

  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String authToken,
  }) async {
    try {
      final user = dpLocator<AuthLocalDataSource>().getUserProfile();
      if (user == null) {
        throw Exception('User profile not found');
      }

      final response = await dio.put(
        '$_baseUrl/api/auth/users/${user.id}/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-F',
          'Authorization': 'Bearer $authToken',
        }),
        data: {
          'username': email,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['detail'] ??
                response.data?['error'] ??
                'Profile update failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Profile update failed');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword1,
    required String newPassword2,
    required String authToken,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/auth/users/change-password/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-F',
          'Authorization': 'Bearer $authToken',
        }),
        data: {
          'old_password': oldPassword,
          'new_password': newPassword1,
          'confirm_new_password': newPassword2,
        },
      );

      if (response.statusCode == 200) {
        return;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['detail'] ??
                response.data ??
                'Password change failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ??
          e.response?.data?.toString() ??
          e.message ??
          'Password change failed');
    }
  }
}
