import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audio_service/audio_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';

import 'package:deup/gen/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/storages/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/database/entity/index.dart';
import 'package:deup/services/player_notification_service.dart';

class VideoPlayerController extends SuperController {
  final object = ObjectModel().obs;
  final objects = <ObjectModel>[].obs;
  final currentName = ''.obs; // 当前播放文件名
  final currentIndex = 0.obs; // 当前播放文件下标
  final thumbnail = ''.obs; // 视频缩略图
  final httpHeaders = Map<String, String>().obs; // http 请求头
  final isLoading = true.obs; // 是否正在加载
  final isAutoPaused = false.obs; // 是否自动暂停
  final fijkViewKey = GlobalKey(); // 播放器 key

  // 字幕 & 音轨
  final subtitles = <Subtitle>[].obs; // 字幕
  final subtitleNameList = <String>[].obs; // 字幕文件名列表
  final subtitleName = ''.obs; // 当前字幕文件名
  final audioTracks = <Map<String, String>>[].obs; // 音轨
  final timedTextTracks = <Map<String, String>>[].obs; // 字幕
  final showTimedText = true.obs; // 是否显示内置字幕
  final showPlaylist = false.obs; // 是否显示播放列表

  // 自动播放
  final isAutoPlay = Get.find<PreferencesStorage>().isAutoPlay.val;

  // 后台播放
  final isBackgroundPlay = Get.find<PreferencesStorage>().isBackgroundPlay.val;

  // 播放模式
  final playMode = Get.find<PreferencesStorage>().playMode;

  // 获取参数
  String id = Get.arguments['id'] ?? '';

  // 下载页面点击
  final String file = Get.arguments['file'] ?? '';
  final int downloadId = Get.arguments['downloadId'] ?? 0;

  // 初始化播放器
  final FijkPlayer player = FijkPlayer();
  final serverId = PluginRuntimeService.to.server?.id;
  final audioHandler = PlayerNotificationService.to.audioHandler;

  Timer? _timer;
  Timer? _timerProgress;
  int _progressId = 0; // 进度表 ID
  final currentPos = Duration.zero.obs;
  final timerDuration = Duration.zero.obs;
  StreamSubscription? _currentPosSubs;
  MediaItem? _mediaItem;

  @override
  void onInit() async {
    super.onInit();

    // 获取当前名称
    currentName.value =
        Get.arguments != null ? Get.arguments['name'] ?? '' : '';

    // 过滤掉非视频文件
    List<ObjectModel> _objects = Get.arguments['objects'] ?? [];
    objects.value = _objects
        .where((o) =>
            PreviewHelper.isVideo(o.name ?? '') || o.type == ObjectType.VIDEO)
        .toList();

    if (file.isEmpty) {
      try {
        final _tmp = await PluginRuntimeService.to.get(
          Get.arguments['object'] ?? ObjectModel(),
        );
        if (_tmp == null) throw '无法获取对象信息';
        object.value = _tmp;
        httpHeaders.value = ObjectHelper.getHeaders(object.value) ?? {};
      } catch (e) {
        SmartDialog.showToast('文件信息获取失败');
        return;
      }
    } else {
      final download = await DatabaseService.to.database.downloadDao
          .findDownloadById(downloadId);
      object.value = ObjectModel.fromJson({
        'id': download?.objectId,
        'name': download?.name,
        'type': download?.type,
        'size': download?.size,
        'url': 'file://${file}',
      });

      // 如果存在服务, 尝试获取关联字幕
      if (serverId != null) {
        PluginRuntimeService.to.get(object.value).then((value) {
          updateSubtitleNameList(value?.related ?? []);
        });
      }
    }

    // 获取字幕文件名列表
    currentName.value = object.value.name ?? '';
    updateSubtitleNameList(object.value.related ?? []);
    thumbnail.value = object.value.cover ??
        object.value.poster ??
        object.value.thumbnail ??
        '';

    // 如果有关联对象
    if (object.value.related != null) {
      final _related = object.value.related!
          .where((o) =>
              PreviewHelper.isVideo(o.name ?? '') || o.type == ObjectType.VIDEO)
          .toList();
      if (_related.isNotEmpty) objects.value = _related;
    }

    // 当前播放文件下标
    currentIndex.value = objects.indexWhere((o) => o.id == id);
    showPlaylist.value = objects.length > 1; // 是否显示播放列表

    // PlayerNotificationService
    audioHandler.initializeStreamController(player, showPlaylist.value, true);
    audioHandler.playbackState.addStream(audioHandler.streamController.stream);
    audioHandler.setVideoFunctions(
        player.start, player.pause, player.seekTo, player.stop);

    // 更新播放进度
    await updateProgress();

    // 初始化播放器
    await FijkHelper.setFijkOption(player, headers: httpHeaders);
    await player.setOption(FijkOption.playerCategory, 'seek-at-start',
        currentPos.value.inMilliseconds);
    await player.setDataSource(object.value.url ?? '', autoPlay: isAutoPlay);

    // Listener
    player.addListener(_fijkValueListener);

    // 监听播放进度
    _currentPosSubs = player.onCurrentPosUpdate.listen((v) {
      currentPos.value = v;
    });

    // 绑定进度监听
    DownloadService.to.bindBackgroundIsolate((id, status, progress) {});
    isLoading.value = false; // 加载完成
  }

  /// todo 切到后台, 播放其他 app 声音源再暂停, 再切回来, 会自动播放, 但是声音消失了
  void _fijkValueListener() async {
    FijkValue value = player.value;

    // Android 有些情况下会拿不到播放时间, 特殊处理一下
    if (_mediaItem != null && _mediaItem!.duration != value.duration) {
      _playerNotificationHandler();
    }

    // 屏幕常亮切换
    if (value.state == FijkState.started) WakelockPlus.enable();
    if (value.state == FijkState.idle ||
        value.state == FijkState.completed ||
        value.state == FijkState.paused) WakelockPlus.disable();

    // 播放预加载完成
    if (value.state == FijkState.prepared) {
      if (value.duration.inMilliseconds > 0 || object.value.isLive == true) {
        _playerNotificationHandler();
      }

      // 获取视频/音轨信息
      await _getTrackInfo();
    }

    // 播放完成
    if (value.state == FijkState.completed) {
      currentPos.value = Duration.zero;

      // 更新播放进度 - 重置
      if (serverId != null) {
        await DatabaseService.to.database.progressDao.updateProgress(
          ProgressEntity(
            id: _progressId,
            serverId: serverId!,
            objectId: id,
            currentPos: currentPos.value.inMilliseconds,
            duration: player.value.duration.inMilliseconds,
          ),
        );
      }

      // 列表循环
      if (playMode.val == PlayMode.LIST_LOOP && showPlaylist.isTrue) {
        await player.seekTo(0);
        currentIndex.value == objects.length - 1
            ? changePlaylist(0)
            : changePlaylist(currentIndex.value + 1);
        return;
      }

      // 单集循环
      if (playMode.val == PlayMode.SINGLE_LOOP && showPlaylist.isTrue) {
        await player.seekTo(0);
        await player.start();
        return;
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

  /// 获取音轨 & 字幕信息
  Future<void> _getTrackInfo() async {
    final trackInfo = await player.getTrackInfo(); // 获取音轨信息
    final _audioTracks = <Map<String, String>>[];
    final _timedTextTracks = <Map<String, String>>[];
    for (var index = 0; index < trackInfo.length; index++) {
      final track = trackInfo[index];
      if (track['type'] == IjkPlayerTrackType.AUDIO) {
        _audioTracks.add({
          'index': index.toString(),
          'title': CommonUtils.formatIjkTrack(track['title']),
          'language': track['language'],
          'info': track['info'],
        });
      } else if (track['type'] == IjkPlayerTrackType.TIMEDTEXT) {
        _timedTextTracks.add({
          'index': index.toString(),
          'title': CommonUtils.formatIjkTrack(track['title']),
          'language': track['language'],
          'info': track['info'],
        });
      }
    }
    audioTracks.value = _audioTracks;
    timedTextTracks.value = _timedTextTracks;
  }

  /// 切换播放列表
  ///
  /// [index] 播放列表下标
  void changePlaylist(int index) async {
    final _object = objects[index];
    if (index == currentIndex.value) {
      SmartDialog.showToast('正在播放该视频');
      return;
    }

    // 获取视频播放地址
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

    // 更新初始化信息
    id = _object.id ?? '';
    currentIndex.value = index;
    currentName.value = _object.name ?? '';
    isAutoPaused.value = false;
    subtitles.clear();
    audioTracks.clear();
    timedTextTracks.clear();

    // 获取字幕文件名列表
    updateSubtitleNameList(object.value.related ?? []);

    // 重置播放器信息
    SmartDialog.dismiss();
    player.reset().then((value) async {
      currentPos.value = Duration.zero;
      await updateProgress(); // 更新播放进度

      // 更新封面
      final _cover = PreviewHelper.isAudio(_object.name ?? '')
          ? Assets.common.logo.image()
          : ((_object.cover != null && _object.cover!.isNotEmpty) ||
                  (_object.poster != null && _object.poster!.isNotEmpty) ||
                  (_object.thumbnail != null && _object.thumbnail!.isNotEmpty))
              ? Image.network(
                  _object.cover ?? _object.poster ?? _object.thumbnail ?? '',
                  headers: ObjectHelper.getHeaders(object.value))
              : null;
      await player.setCover(_cover?.image);

      // 初始化播放器
      await FijkHelper.setFijkOption(player,
          headers: ObjectHelper.getHeaders(object.value));
      await player.setOption(FijkOption.playerCategory, 'seek-at-start',
          currentPos.value.inMilliseconds);
      await player.setDataSource(object.value.url ?? '', autoPlay: true);
      SmartDialog.showToast('切换成功');
    });
  }

  /// 切换字幕
  ///
  /// [value] 字幕文件名
  void changeSubtitle({String? value}) async {
    if (value == null) {
      value = await showModalActionSheet(
        context: Get.overlayContext!,
        materialConfiguration: MaterialModalActionSheetConfiguration(),
        title: '切换字幕',
        actions: [
          ...subtitleNameList.map(
            (v) => SheetAction(label: v, key: v),
          ),
          ...timedTextTracks.map(
            (v) => SheetAction(
              label: '${v['title']}(${v['language']})',
              key: 'internal::${v['index']}',
            ),
          ),
          SheetAction(
            label: '关闭字幕',
            key: 'close',
            isDestructiveAction: true,
          ),
        ],
        cancelLabel: '取消',
      );
    }
    if (value == null) return;

    // 关闭字幕
    if (value == 'close') {
      showTimedText.value = false;
      subtitles.value = [];
      subtitles.refresh();
      SmartDialog.showToast('字幕已关闭');
      return;
    }

    // 切换内置字幕
    if (value.startsWith('internal::')) {
      final _value = value.replaceAll('internal::', '');
      final track = await player.getSelectedTrack(IjkPlayerTrackType.TIMEDTEXT);
      if (track == int.parse(_value)) {
        if (showTimedText.value) {
          SmartDialog.showToast('当前字幕, 无需切换');
        }

        if (!showTimedText.value) {
          SmartDialog.showToast('切换成功');
        }

        showTimedText.value = true; // 显示字幕
        return;
      }

      player.pause();
      Future.delayed(Duration(milliseconds: 500), () async {
        await player.selectTrack(int.parse(_value));
        await player.seekTo(currentPos.value.inMilliseconds);
        await player.start();

        showTimedText.value = true; // 显示字幕
        SmartDialog.showToast('切换成功');
      });
      return;
    }

    try {
      SmartDialog.showLoading(msg: '切换中...');

      // 获取关联的对象信息
      final _related =
          object.value.related?.firstWhere((element) => element.name == value);

      // 获取字幕文件
      final _object = await PluginRuntimeService.to.get(_related);
      if (_object == null) throw '无法获取对象信息';
      final response = await DioService.to.dio.get(
        _object.url!,
        options: Options(
          headers: ObjectHelper.getHeaders(_object),
          responseDecoder: (List<int> responseBytes, RequestOptions options,
              ResponseBody responseBody) {
            String _data = '';
            try {
              _data = hasUtf32Bom(responseBytes)
                  ? utf32.decode(responseBytes)
                  : (hasUtf16Bom(responseBytes)
                      ? utf16.decode(responseBytes)
                      : utf8.decode(responseBytes));
            } catch (e) {
              _data = gbk.decode(responseBytes);
            }
            return _data;
          },
        ),
      );

      // 获取文件后缀
      final ext = p.extension(value).toLowerCase();

      // ass 单独处理
      if (ext == '.ass') {
        showTimedText.value = false;
        subtitles.value = await CommonUtils.ass2srt(response.data);
        subtitles.refresh();

        SmartDialog.dismiss();
        SmartDialog.showToast('切换成功');
        return;
      }

      // 字幕类型
      final subtitleType =
          ext == '.vtt' ? SubtitleType.webvtt : SubtitleType.srt;

      // 解析字幕文件
      final data = await SubtitleDataRepository(
        subtitleController: SubtitleController(
            subtitlesContent: response.data, subtitleType: subtitleType),
      ).getSubtitles();

      showTimedText.value = false;
      subtitles.value = data.subtitles;
      subtitles.refresh();

      SmartDialog.dismiss();
      SmartDialog.showToast('切换成功');
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('切换字幕失败');
    }
  }

  /// 切换音轨
  ///
  /// [value] 音轨文件名
  void changeAudioTrack({String? value}) async {
    if (value == null) {
      value = await showModalActionSheet(
        context: Get.overlayContext!,
        title: '切换音轨',
        actions: [
          ...audioTracks.map(
            (v) => SheetAction(
              label: '${v['title']}(${v['language']})',
              key: v['index'],
            ),
          ),
        ],
        cancelLabel: '取消',
      );
    }

    if (value != null) {
      final track = await player.getSelectedTrack(IjkPlayerTrackType.AUDIO);
      if (track == int.parse(value)) {
        SmartDialog.showToast('当前音轨, 无需切换');
        return;
      }

      player.pause();
      Future.delayed(Duration(milliseconds: 500), () async {
        await player.selectTrack(int.parse(value!));
        await player.seekTo(currentPos.value.inMilliseconds);
        await player.start();
        SmartDialog.showToast('切换成功');
      });
    }
  }

  /// 更新字幕文件名列表
  ///
  /// [related] 相关文件列表
  void updateSubtitleNameList(List<ObjectModel> related) {
    subtitleNameList.clear();
    related.forEach((v) {
      final ext = p.extension(v.name ?? '').toLowerCase();
      if (ext == '.vtt' || ext == '.srt' || ext == '.ass') {
        subtitleNameList.add(v.name ?? '');
      }
    });
  }

  /// 更新本地播放进度
  Future<void> updateProgress() async {
    if (serverId == null || object.value.isLive == true) return;
    final progress = await DatabaseService.to.database.progressDao
        .findProgressByServerIdAndObjectId(serverId!, id);

    if (progress != null) {
      _progressId = progress.id!;
      currentPos.value = Duration(milliseconds: progress.currentPos);
    } else {
      _progressId =
          await DatabaseService.to.database.progressDao.insertProgress(
        ProgressEntity(
          serverId: serverId!,
          objectId: id,
          currentPos: 0,
          duration: player.value.duration.inMilliseconds,
        ),
      );
    }

    // 每五秒记录一下播放进度
    _timerProgress?.cancel();
    _timerProgress = Timer.periodic(Duration(seconds: 5), (timer) async {
      await DatabaseService.to.database.progressDao.updateProgress(
        ProgressEntity(
          id: _progressId,
          serverId: serverId!,
          objectId: id,
          currentPos: currentPos.value.inMilliseconds,
          duration: player.value.duration.inMilliseconds,
        ),
      );
    });
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
        player.pause();
      }
    });

    SmartDialog.showToast('${value}分钟后关闭');
  }

  /// 下载文件
  void download() async {
    DownloadHelper.file(object.value);
  }

  /// 打开 Infuse
  void playWithInfuse() async {
    final uri = Uri.parse(
        'infuse://x-callback-url/play?url=${Uri.encodeComponent(object.value.url!)}');
    await launchUrl(uri);
  }

  @override
  void onPaused() {
    if (player.value.state == FijkState.started && !isBackgroundPlay) {
      isAutoPaused.value = true;
      player.pause();
    }
  }

  @override
  void onResumed() {
    // 判断大小超过 30g 的大文件
    final isLargeFile = object.value.size! > 30 * 1024 * 1024 * 1024;

    // if player is started and auto paused
    if (player.value.state == FijkState.started && isLargeFile) {
      isAutoPaused.value = true;
      player.pause();
    }

    // fix player seekTo bug
    Future.delayed(Duration(milliseconds: 500), () async {
      if (isLargeFile) await player.seekTo(currentPos.value.inMilliseconds);

      if (player.value.state == FijkState.paused && isAutoPaused.isTrue) {
        isAutoPaused.value = false;
        player.start();
      }
    });
  }

  @override
  void onInactive() {}

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onClose() {
    super.onClose();

    _timer?.cancel();
    _timerProgress?.cancel();
    _currentPosSubs?.cancel();
    audioHandler.streamController.add(PlaybackState());
    audioHandler.streamController.close();
    player.removeListener(_fijkValueListener);
    player.release();

    DownloadService.to.unbindBackgroundIsolate();
    WakelockPlus.disable();
  }
}
