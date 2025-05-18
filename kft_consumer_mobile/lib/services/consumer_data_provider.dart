import 'package:dio/dio.dart';
import 'package:kft_consumer_mobile/lib.dart';

class ConsumerDataProvider {
  final Dio dio;
  final String _baseUrl = baseUrl;

  ConsumerDataProvider({required this.dio});

  Future<Map<String, dynamic>> payUtility({
    required String utilityType,
    required double amount,
    String? meterNumber,
    String? phoneNumber,
    String? agentEmail,
    required String authToken,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/consumer/pay-utility/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-F',
          'Authorization': 'Bearer $authToken',
        }),
        data: {
          'utility_type': utilityType,
          'amount': amount,
          if (meterNumber != null && meterNumber.isNotEmpty)
            'meter_number': meterNumber,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phone_number': phoneNumber,
          if (agentEmail != null && agentEmail.isNotEmpty)
            'agent_email': agentEmail,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['message'] ??
                'Payment failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Payment failed');
    }
  }

  Future<List<ProductModel>> getProducts({required String authToken}) async {
    try {
      final response = await dio.get(
        '$_baseUrl/api/merchant/products/',
        options: Options(headers: <String, String>{
          'Authorization': 'Bearer $authToken',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> productListJson = response.data;
        return productListJson
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['message'] ??
                'Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Failed to fetch products');
    }
  }

  Future<List<TransactionModel>> getTransactionHistory(
      {required String authToken}) async {
    try {
      final response = await dio.get(
        '$_baseUrl/api/consumer/transactions/',
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
        '$_baseUrl/api/consumer/profile/',
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

  Future<Map<String, dynamic>> buyProduct({
    required int productId,
    required String authToken,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/api/consumer/buy-product/',
        options: Options(headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-F',
          'Authorization': 'Bearer $authToken',
        }),
        data: {
          'product_id': productId,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: response.data?['error'] ??
                response.data?['message'] ??
                'Product purchase failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message ??
          'Product purchase failed');
    }
  }
}
