import 'package:get_storage/get_storage.dart';

class UserStorage {
  // 初始化偏好设置存储
  static final _prefBox = () => GetStorage('UserStorage');

  // Init
  Future<UserStorage> init() async {
    await GetStorage.init('UserStorage');
    return this;
  }

  final id = ''.val('id', getBox: _prefBox); // UserId
}
