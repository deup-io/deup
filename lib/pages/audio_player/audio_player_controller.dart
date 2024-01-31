import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:audio_service/audio_service.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/models/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/helper/fijk_helper.dart';

class AudioPlayerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isPlaylist = false.obs; // 是否显示为播放列表
  final object = ObjectModel().obs; // 文件信息
  final objects = <ObjectModel>[].obs;
  final isLoading = true.obs; // 是否正在加载
  final playMode = PlayMode.LIST_LOOP.obs; // 播放模式

  // 获取参数
  String id = Get.arguments['id'] ?? '';

  // 下载页面点击
  final String file = Get.arguments['file'] ?? '';
  final int downloadId = Get.arguments['downloadId'] ?? 0;

  // 当前播放音频
  final currentName = ''.obs;
  final currentIndex = 0.obs;
  final FijkPlayer player = FijkPlayer();
  final audioHandler = PlayerNotificationService.to.audioHandler;
  late TabController tabController;

  double seekPos = -1.0.obs;
  final isPlaying = false.obs;
  final duration = Duration().obs;
  final currentPos = Duration().obs;
  final bufferPos = Duration().obs;

  Timer? _timer;
  final timerDuration = Duration.zero.obs;
  StreamSubscription? _currentPosSubs;
  StreamSubscription? _bufferPosSubs;
  StreamSubscription? _bufferingSubs;
  MediaItem? _mediaItem;

  @override
  void onInit() async {
    super.onInit();

    // 获取当前名称
    currentName.value =
        Get.arguments != null ? Get.arguments['name'] ?? '' : '';

    // TabController
    tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    tabController.addListener(() {
      isPlaylist.value = tabController.index == 1;
    });

    // 过滤非音频
    List<ObjectModel> _objects = Get.arguments['objects'] ?? [];
    objects.value = _objects
        .where((o) =>
            PreviewHelper.isAudio(o.name ?? '') || o.type == ObjectType.AUDIO)
        .toList();

    // 获取文件信息
    if (file.isEmpty) {
      try {
        final _tmp = await PluginRuntimeService.to.get(
          Get.arguments['object'] ?? ObjectModel(),
        );
        if (_tmp == null) throw '无法获取对象信息';
        object.value = _tmp;
      } catch (e) {
        SmartDialog.showToast(e.toString());
        return;
      }
    } else {
      final download = await DatabaseService.to.database.downloadDao
          .findDownloadById(downloadId);
      object.value = ObjectModel.fromJson({
        'name': download?.name,
        'type': download?.type,
        'size': download?.size,
        'url': 'file://${file}',
      });
    }

    // 如果有关联对象
    if (object.value.related != null) {
      final _related = object.value.related!
          .where((o) =>
              PreviewHelper.isAudio(o.name ?? '') || o.type == ObjectType.AUDIO)
          .toList();
      if (_related.isNotEmpty) objects.value = _related;
    }

    // 当前播放文件名
    currentName.value = object.value.name ?? '';
    currentIndex.value = objects.indexWhere((o) => o.id == id); // 当前播放文件下标

    // PlayerNotificationService
    audioHandler.initializeStreamController(player, objects.length > 1, false);
    audioHandler.playbackState.addStream(audioHandler.streamController.stream);
    audioHandler.setVideoFunctions(
        player.start, player.pause, player.seekTo, player.stop);

    // 初始化播放器
    await FijkHelper.setFijkOption(player,
        isAudioOnly: true, headers: ObjectHelper.getHeaders(object.value));
    await player.setOption(FijkOption.playerCategory, 'seek-at-start',
        currentPos.value.inMilliseconds);
    await player.setDataSource(object.value.url ?? '', autoPlay: true);

    // Listener
    player.addListener(_fijkValueListener);

    // 监听播放进度
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      currentPos.value = v;
    });

    _bufferPosSubs = player.onBufferPosUpdate.listen((v) {
      bufferPos.value = v;
    });

    _bufferingSubs = player.onBufferStateUpdate.listen((v) {
      Future.delayed(Duration(milliseconds: 1000), () {
        audioHandler.updatePlaybackState(player);
      });
    });

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
    isLoading.value = false;
  }

  void _fijkValueListener() async {
    FijkValue value = player.value;
    isPlaying.value = value.state == FijkState.started;

    // 获取视频的总长度
    if (value.duration != duration.value) {
      duration.value = value.duration;
    }

    // Android 有些情况下会拿不到播放时间, 特殊处理一下
    if (_mediaItem != null && _mediaItem!.duration != value.duration) {
      _playerNotificationHandler();
    }

    // 播放预加载完成
    if (value.state == FijkState.prepared) {
      if (value.duration.inMilliseconds > 0 || object.value.isLive == true) {
        _playerNotificationHandler();
      }
    }

    // 播放完成
    if (value.state == FijkState.completed) {
      currentPos.value = Duration.zero;

      // 根据播放模式切换下一首
      switch (playMode.value) {
        case PlayMode.SINGLE_LOOP:
          player.seekTo(0);
          player.start();
          break;
        case PlayMode.LIST_LOOP:
          if (objects.length == 1) {
            player.seekTo(0);
            player.start();
          } else {
            currentIndex.value == objects.length - 1
                ? changePlaylist(0)
                : changePlaylist(currentIndex.value + 1);
          }
          break;
        case PlayMode.SHUFFLE:
          if (objects.length == 1) {
            player.seekTo(0);
            player.start();
          } else {
            changePlaylist(CommonUtils.randomInt(0, objects.length - 1));
          }
          break;
        default:
          break;
      }
    }
  }

  /// 通知栏控制器
  void _playerNotificationHandler() {
    _mediaItem = MediaItem(
      id: object.value.id ?? '',
      title: CommonUtils.formatFileNme(currentName.value),
      duration: player.value.duration,
      artUri:
          object.value.thumbnail != null && object.value.thumbnail!.isNotEmpty
              ? Uri.parse(object.value.thumbnail!)
              : Uri.parse(kDefaultLogoImageUrl),
      artHeaders: ObjectHelper.getHeaders(object.value) ?? {},
    );

    // Add media
    audioHandler.mediaItem.add(_mediaItem);
  }

  /// 切换播放列表文件
  /// [index] 下标
  void changePlaylist(int index) async {
    final _object = objects[index];
    if (index == currentIndex.value) {
      SmartDialog.showToast('当前播放文件');
      return;
    }

    // 获取文件信息
    SmartDialog.showLoading();
    try {
      final _tmp = await PluginRuntimeService.to.get(_object);
      if (_tmp == null) throw '无法获取对象信息';
      object.value = _tmp;
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
      return;
    }

    // 更新当前播放文件信息
    id = _object.id ?? '';
    currentIndex.value = index;
    currentName.value = _object.name ?? '';

    // 重置播放器信息
    SmartDialog.dismiss();
    player.reset().then((value) async {
      currentPos.value = Duration.zero;

      // 初始化播放器
      await FijkHelper.setFijkOption(player,
          isAudioOnly: true, headers: ObjectHelper.getHeaders(object.value));
      await player.setOption(FijkOption.playerCategory, 'seek-at-start',
          currentPos.value.inMilliseconds);
      await player.setDataSource(object.value.url ?? '', autoPlay: true);
    });
  }

  /// 定时关闭
  void timedShutdown() async {
    final _hasTimer = timerDuration.value.inSeconds > 0;
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      title:
          '定时关闭${_hasTimer ? '(剩余${timerDuration.value.inMinutes + 1}分钟)' : ''}',
      actions: [
        SheetAction(label: '5分钟', key: 5),
        SheetAction(label: '10分钟', key: 10),
        SheetAction(label: '15分钟', key: 15),
        SheetAction(label: '30分钟', key: 30),
        SheetAction(label: '60分钟', key: 60),
        ...[
          if (_hasTimer)
            SheetAction(label: '关闭定时', key: 0, isDestructiveAction: true)
        ].whereType<SheetAction>().toList(),
      ],
      cancelLabel: '取消',
    );
    if (value == null) return;

    // 关闭定时
    if (value == 0) {
      _timer?.cancel();
      timerDuration.value = Duration.zero;
      SmartDialog.showToast('关闭定时');
      return;
    }

    _timer?.cancel();
    timerDuration.value = Duration(minutes: value);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      timerDuration.value = timerDuration.value - Duration(seconds: 1);
      if (timerDuration.value.inSeconds == 0) {
        _timer?.cancel();
        Get.find<AudioPlayerController>().player.pause();
      }
    });

    SmartDialog.showToast('${value}分钟后关闭');
  }

  /// 切换播放速度
  void changeSpeed() async {
    final value = await showModalActionSheet(
      context: Get.overlayContext!,
      title: '播放速度',
      materialConfiguration: MaterialModalActionSheetConfiguration(),
      actions: [
        SheetAction(label: '2.0X', key: 2.0),
        SheetAction(label: '1.8X', key: 1.8),
        SheetAction(label: '1.5X', key: 1.5),
        SheetAction(label: '1.2X', key: 1.2),
        SheetAction(label: '1.0X', key: 1.0),
        SheetAction(label: '0.5X', key: 0.5),
        SheetAction(label: '恢复默认', key: 1.0),
      ],
      cancelLabel: '取消',
    );
    if (value == null) return;
    player.setSpeed(value);
    SmartDialog.showToast('切换成功');
  }

  /// 下载文件
  void download() async {
    DownloadHelper.file(object.value);
  }

  @override
  void onClose() {
    super.onClose();

    _timer?.cancel();
    _currentPosSubs?.cancel();
    _bufferPosSubs?.cancel();
    _bufferingSubs?.cancel();
    audioHandler.streamController.add(PlaybackState());
    audioHandler.streamController.close();
    player.removeListener(_fijkValueListener);
    player.release();

    DownloadService.to.unbindBackgroundIsolate();
  }
}
