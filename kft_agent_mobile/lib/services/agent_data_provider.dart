import 'package:dio/dio.dart';
import 'package:kft_agent_mobile/lib.dart';

class AgentDataProvider {
  final Dio dio;
  final String _baseUrl = baseUrl;

  AgentDataProvider({required this.dio});

  Future<Map<String, dynamic>> cashInToConsumer({
    required String consumerEmail,
    required double amount,
    required String authToken,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/agent/cash-in/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        }),
        data: {
          'consumer_email': consumerEmail,
          'amount': amount.toStringAsFixed(2),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['detail'] ??
                response.data?['message'] ??
                'Cash-in failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Cash-in failed');
    }
  }

  Future<List<TransactionModel>> getTransactionHistory(
      {required String authToken}) async {
    try {
      final response = await dio.get(
        '$_baseUrl/api/agent/transactions/',
        options: Options(headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> transactionListJson = response.data;
        return transactionListJson
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['message'] ??
                'Failed to fetch transaction history');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Failed to fetch transaction history');
    }
  }

  Future<UserModel> getUserProfile({required String authToken}) async {
    try {
      final response = await dio.get(
        '$_baseUrl/api/agent/profile/',
        options: Options(headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        }),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['message'] ??
                'Failed to fetch user profile');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Failed to fetch user profile');
    }
  }

  Future<Map<String, dynamic>> payUtilityAsAgent({
    required String utilityType,
    required double amount,
    String? meterNumber,
    String? phoneNumber,
    required String authToken,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'utility_type': utilityType,
        'amount': amount.toStringAsFixed(2),
      };
      if (meterNumber != null && meterNumber.isNotEmpty) {
        data['meter_number'] = meterNumber;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phone_number'] = phoneNumber;
      }

      final response = await dio.post(
        '$_baseUrl/api/agent/pay-utility/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $authToken',
        }),
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['detail'] ??
                response.data?['message'] ??
                'Utility payment failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['detail'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Utility payment failed');
    }
  }
}
