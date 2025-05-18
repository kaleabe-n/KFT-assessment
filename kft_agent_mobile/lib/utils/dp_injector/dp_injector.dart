import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:kft_agent_mobile/lib.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dpLocator = GetIt.instance;
Future<void> serviceLocatorInit() async {
  //
  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.addAll(
    [
      AwesomeDioInterceptor(),
    ],
  );
  dpLocator.registerLazySingleton<Dio>(
    () => dio,
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  dpLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );
  // FlutterSecureStorage
  const secureStorage = FlutterSecureStorage();
  dpLocator.registerLazySingleton<FlutterSecureStorage>(
    () => secureStorage,
  );

  // Data Providers / Data Sources
  dpLocator.registerLazySingleton<AuthDataProvider>(
    () => AuthDataProvider(
      dio: dpLocator<Dio>(),
    ),
  );

  dpLocator.registerLazySingleton<AgentDataProvider>(
    () => AgentDataProvider(
      dio: dpLocator<Dio>(),
    ),
  );

  dpLocator.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      sharedPreferences: dpLocator<SharedPreferences>(),
      secureStorage: dpLocator<FlutterSecureStorage>(),
    ),
  );

  // Blocs
  dpLocator.registerFactory<LoginBloc>(
    () => LoginBloc(
      authDataProvider: dpLocator<AuthDataProvider>(),
    ),
  );
  dpLocator.registerFactory<SignUpBloc>(
    () => SignUpBloc(
      authDataProvider: dpLocator<AuthDataProvider>(),
    ),
  );
  dpLocator.registerFactory<OtpBloc>(
    () => OtpBloc(
      authDataProvider: dpLocator<AuthDataProvider>(),
    ),
  );

  dpLocator.registerFactory<UtilityPaymentBloc>(
    () => UtilityPaymentBloc(
      agentDataProvider: dpLocator<AgentDataProvider>(),
      authLocalDataSource: dpLocator<AuthLocalDataSource>(),
    ),
  );

  dpLocator.registerFactory<CashInBloc>(
    () => CashInBloc(
      agentDataProvider: dpLocator<AgentDataProvider>(),
    ),
  );

  dpLocator.registerFactory<TransactionsBloc>(
    () => TransactionsBloc(
      agentDataProvider: dpLocator<AgentDataProvider>(),
      authLocalDataSource: dpLocator<AuthLocalDataSource>(),
    ),
  );
  dpLocator.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      agentDataProvider: dpLocator<AgentDataProvider>(),
      authLocalDataSource: dpLocator<AuthLocalDataSource>(),
    ),
  );

  dpLocator.registerFactory<UpdateProfileBloc>(
    () => UpdateProfileBloc(
      authDataProvider: dpLocator<AuthDataProvider>(),
      authLocalDataSource: dpLocator<AuthLocalDataSource>(),
    ),
  );
  dpLocator.registerFactory<ChangePasswordBloc>(
    () => ChangePasswordBloc(
      authDataProvider: dpLocator<AuthDataProvider>(),
      authLocalDataSource: dpLocator<AuthLocalDataSource>(),
    ),
  );
}
