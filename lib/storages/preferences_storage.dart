import 'package:get_storage/get_storage.dart';

class PreferencesStorage {
  // 初始化偏好设置存储
  static final _prefBox = () => GetStorage('PreferencesStorage');

  // Init
  Future<PreferencesStorage> init() async {
    await GetStorage.init('PreferencesStorage');
    return this;
  }

  // 是否是第一次启动
  final isFirstOpen = true.val('isFirstOpen', getBox: _prefBox);

  // 是否自动播放
  final isAutoPlay = true.val('isAutoPlay', getBox: _prefBox);

  // 是否后台播放
  final isBackgroundPlay = true.val('isBackgroundPlay', getBox: _prefBox);

  // 是否开启硬件解码
  final isHardwareDecode = true.val('isHardwareDecode', getBox: _prefBox);

  // 播放模式 - 列表循环, 单集循环, 播完暂停
  final playMode = 0.val('playMode', getBox: _prefBox);
}
