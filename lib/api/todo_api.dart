import 'package:dio/dio.dart';
import 'package:nigh/api/model/todo.dart';
import 'package:retrofit/retrofit.dart';

import '../api_client.dart';
import '../api_response.dart';
import '../constant.dart';

part 'todo_api.g.dart';

@RestApi()
abstract class TodoApi {
  factory TodoApi() {
    return _instance;
  }

  static final dio = ApiClient().dio;
  static final _instance = _TodoApi(dio, baseUrl: '$kApiUrl/todos');

  @GET('/')
  Future<ApiResponse<List<Todo>>> getTodos({
    @Query("date") required String date,
  });

  @POST('')
  Future<ApiResponse<Todo>> addTodo({
    @Field() required String date,
    @Field() required String title,
    @Field("reminder_time") required String? reminderTime,
  });

  @PUT('/complete')
  Future<void> complete({
    @Query('id') required int id,
  });

  @PUT('/{id}')
  Future<void> edit({
    @Path('id') required int id,
    @Field('title') required String title,
    @Field("reminder_time") required String? reminderTime,
  });

  @DELETE('/{id}')
  Future<void> delete({
    @Path('id') required int id,
  });
}
