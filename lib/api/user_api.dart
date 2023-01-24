import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../api_client.dart';
import '../api_response.dart';
import '../constant.dart';
import 'model/user.dart';

part 'user_api.g.dart';

@RestApi()
abstract class UserApi {
  factory UserApi() {
    return _instance;
  }

  static final dio = ApiClient().dio;
  static final _instance = _UserApi(dio, baseUrl: '$kApiUrl/user');

  @POST('/login')
  Future<ApiResponse<User>> login({
    @Field() required String? username,
    @Field() required String? password
  });

  @POST('/register')
  Future<ApiResponse<User>> register({
    @Field() required String username,
    @Field('first_name') required String firstName,
    @Field('last_name') required String lastName,
    @Field() required String password
  });

  @POST('/request_reset_password')
  Future<ApiResponse<User?>> requestResetPassword({
    @Field() required String username,
    @Field() required String email
  });

  @POST('/verify_reset_password')
  Future<ApiResponse<bool>> verifyResetPassword({
    @Field("user_id") required int userId,
    @Field() required String code
  });

  @POST('/reset_password')
  Future<ApiResponse<bool>> resetPassword({
    @Field("user_id") required int userId,
    @Field() required String password
  });

  @POST('/delete_user')
  Future<ApiResponse<bool>> deleteUser({
    @Field() required String password
  });
}

