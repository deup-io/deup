import 'package:dio/dio.dart';
import 'package:get/get.dart' show Get, GetxService;
import 'package:get/get_instance/src/extension_instance.dart';

// Dio
class DioService extends GetxService {
  static DioService get to => Get.find();

  // Dio
  Dio _dio = Dio();
  Dio get dio => _dio;

  // 连接超时时间
  static const Duration CONNECT_TIMEOUT = Duration(seconds: 10 * 1000);

  // 响应超时时间
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 10 * 1000);

  // Init
  Future<DioService> init() async {
    // 设置一些默认信息
    _dio.options
      ..connectTimeout = CONNECT_TIMEOUT
      ..receiveTimeout = RECEIVE_TIMEOUT;

    // Interceptor
    _dio.interceptors.add(DioInterceptors());
    return this;
  }
}

class DioInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 错误处理
    if (response.data == null) {
      response.data = {'message': '您的网络不太好, 请刷新页面重试吧', 'code': -1};
    }

    // Next
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    return super.onError(err, handler);
  }
}
