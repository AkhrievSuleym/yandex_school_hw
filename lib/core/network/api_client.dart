import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yandex_shmr_hw/core/network/api_endpoints.dart';

class ApiClient {
  final Dio dio;

  ApiClient() : dio = Dio() {
    dio.options.baseUrl = dotenv.env['API_BASE_URL']!;
    dio.options.connectTimeout = const Duration(seconds: 5000); // 5 секунд
    dio.options.receiveTimeout = const Duration(seconds: 3000); // 3 секунды

    dio.interceptors.add(
      InterceptorsWrapper(
        // Интерцептор для авторизации (Bearer Token)
        onRequest: (options, handler) {
          final authToken = dotenv.env['AUTH_TOKEN'];
          if (authToken != null) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }
          return handler.next(options);
        },
        // Интерцептор для обработки ошибок (включая ретраи)
        onError: (DioException error, handler) async {
          // Проверяем, нужно ли делать ретрай
          if (_shouldRetry(error)) {
            int retries = error.requestOptions.extra['retries'] ?? 0;
            if (retries < 3) {
              error.requestOptions.extra['retries'] = retries + 1;
              final backoffTime = _getBackoffTime(retries);
              await Future.delayed(backoffTime);
              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } on DioException catch (e) {
                return handler.next(e);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Вспомогательная функция для определения, нужно ли делать ретрай
  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return true; // Таймауты всегда ретраим
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      return statusCode == 500 ||
          statusCode == 502 ||
          statusCode == 503 ||
          statusCode == 504 ||
          statusCode == 408 ||
          statusCode == 429;
    }
    return false;
  }

  // Вспомогательная функция для расчета времени задержки (Exponential Backoff)
  Duration _getBackoffTime(int retries) {
    const baseDelayMs = 500;
    return Duration(milliseconds: baseDelayMs * (1 << retries));
  }

  Future<Response> createAccount(Map<String, dynamic> data) async {
    return await dio.post(ApiEndpoints.accounts, data: data);
  }

  Future<Response> getAccount(String id) async {
    return await dio.get('${ApiEndpoints.accounts}/$id');
  }

  Future<Response> updateAccount(String id, Map<String, dynamic> data) async {
    return await dio.put('${ApiEndpoints.accounts}/$id', data: data);
  }

  Future<Response> getAccountHistory(String id) async {
    final path = ApiEndpoints.accountHistory.replaceFirst('{id}', id);
    return await dio.get(path);
  }
}
