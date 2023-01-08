// ignore_for_file: avoid_print
import 'package:dio/dio.dart';

import 'constant.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() {
    setHeader();
    return _instance;
  }

  final Dio dio = Dio(BaseOptions(headers: {
    'Content-Type': 'application/json'
  }));

  ApiClient._() {
    dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options, _) async {
      if (showApiResponse) {
        print('Header: ${options.headers.toString()}');
        print('Call: ${options.method} ${options.baseUrl} path = ${options.path} query = ${options.queryParameters}');
        print('Data: ${options.data}');
      }
      _.next(options);
    }, onResponse: (Response response, _) async {
      if (showApiResponse) {
        print('Result: ${response.data}');
      }
      _.next(response);
    }, onError: (DioError e, _) async {
      if (showApiResponse) {
        print('Error: ${e.response?.data ?? e.error}');
      }
      _.next(e);
    }));
  }
  static setHeader() {
    _instance.dio.options.headers['Authorization'] = "Bearer ${globalSharedPrefs.getString('api_key') ?? ''}";
  }
}