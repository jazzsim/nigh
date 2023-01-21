import 'package:dio/dio.dart';
import 'package:nigh/api/model/diary.dart';
import 'package:retrofit/retrofit.dart';

import '../api_client.dart';
import '../api_response.dart';
import '../constant.dart';

part 'diary_api.g.dart';

@RestApi()
abstract class DiaryApi {
  factory DiaryApi() {
    return _instance;
  }

  static final dio = ApiClient().dio;
  static final _instance = _DiaryApi(dio, baseUrl: '$kApiUrl/diaries');

  @GET('/')
  Future<ApiResponse<List<Diary>>> getDiarys({@Query("date") required String date});

  @POST('')
  Future<ApiResponse<Diary>> addDiary({
    @Field() required String date,
    @Field() required String title,
    @Field() required String content,
  });

  @PUT('/{id}')
  Future<ApiResponse<Diary>> edit({@Path('id') required int id, @Field('title') required String title,  @Field('content') required String content});

  @DELETE('/{id}')
  Future<void> delete({@Path('id') required int id});
}
