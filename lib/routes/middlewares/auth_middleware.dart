import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // 可以在这里进行跳转前的逻辑处理
    // 判断登录
    // ...
  }
}
