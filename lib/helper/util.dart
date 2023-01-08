import 'package:dio/dio.dart';

class Util {
  const Util._();

  static String apiError(Object e) {
    try {
      String err = ((e as DioError).response?.data['message']).toString();
      return err;
    } catch (e) {
      return 'API Error';
    }
  }
}
