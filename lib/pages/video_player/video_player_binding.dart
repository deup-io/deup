import 'package:get/get.dart';

import 'package:deup/pages/video_player/video_player_controller.dart';

class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayerController>(() => VideoPlayerController());
  }
}
