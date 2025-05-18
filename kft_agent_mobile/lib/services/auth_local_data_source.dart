import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  static const String _userProfileCacheKey = 'CACHED_USER_PROFILE';
  static const String _tokenCacheKey = 'AUTH_TOKEN';
  static const String _fcmTokenKey = 'FCM_TOKEN';

  AuthLocalDataSource({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  })  : _secureStorage = secureStorage,
        _sharedPreferences = sharedPreferences;

  UserModel? getUserProfile() {
    final jsonString = _sharedPreferences.getString(_userProfileCacheKey);
    if (jsonString != null) {
      try {
        final userMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserModel(
          id: userMap['id'] ?? 0,
          firstName: userMap['firstName'] ?? '',
          lastName: userMap['lastName'] ?? '',
          email: userMap['email'] ?? '',
          username: userMap['email'] ?? '',
          balance: userMap['balance'] ?? 0.0,
        );
      } catch (e) {
        deleteUserProfile();
        throw Exception('Error decoding cached user profile: ${e.toString()}');
      }
    } else {
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenCacheKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveAuthData(
      {required UserModel userProfile, required String token}) async {
    try {
      await _secureStorage.write(
        key: _tokenCacheKey,
        value: token,
      );
    } catch (e) {
      throw Exception('Failed to cache token: ${e.toString()}');
    }

    try {
      final userProfileMap = {
        'id': userProfile.id,
        'firstName': userProfile.firstName,
        'lastName': userProfile.lastName,
        'email': userProfile.email,
        'balance': userProfile.balance,
        'username': userProfile.username,
      };
      await _sharedPreferences.setString(
        _userProfileCacheKey,
        jsonEncode(userProfileMap),
      );
    } catch (e) {
      await deleteToken();
      throw Exception('Failed to cache user profile: ${e.toString()}');
    }
  }

  Future<void> deleteUserProfile() async {
    try {
      await _sharedPreferences.remove(_userProfileCacheKey);
    } catch (e) {
      throw Exception('Failed to delete cached user profile: ${e.toString()}');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenCacheKey);
    } catch (e) {
      throw Exception('Failed to delete cached token: ${e.toString()}');
    }
  }

  Future<void> deleteUserAndToken() async {
    try {
      await Future.wait([
        deleteUserProfile(),
        deleteToken(),
      ]);
    } catch (e) {
      throw Exception('Failed to clear all cached auth data');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isFirstTimeUser() async {
    final isFirstTime = _sharedPreferences.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      await _sharedPreferences.setBool('isFirstTime', false);
    }
    return isFirstTime;
  }

  Future<void> setFirstTimeUser() async {
    await _sharedPreferences.setBool('isFirstTime', false);
  }

  Future<void> saveFcmToken(String fcmToken) async {
    try {
      await _sharedPreferences.setString(_fcmTokenKey, fcmToken);
    } catch (e) {
      throw Exception('Failed to cache FCM token: $e');
    }
  }

  String? getFcmToken() {
    try {
      return _sharedPreferences.getString(_fcmTokenKey);
    } catch (e) {
      return null;
    }
  }
}
