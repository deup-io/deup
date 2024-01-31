import 'dart:convert';

import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:deup/models/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/helper/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/pages/detail/detail_controller.dart';
import 'package:deup/pages/detail/layouts/image_layout/image_layout_item.dart';

class ImageLayout extends StatefulWidget {
  final String id;
  final bool history;
  final String keyword;
  final ObjectModel? object;
  final DetailController detailController;

  const ImageLayout({
    Key? key,
    required this.id,
    required this.object,
    required this.history,
    required this.keyword,
    required this.detailController,
  }) : super(key: key);

  @override
  _ImageLayoutState createState() => _ImageLayoutState();
}

class _ImageLayoutState extends State<ImageLayout> {
  int offset = 0; // 当前游标
  bool isLoading = false; // 是否正在加载中
  bool isFirstLoading = true; // 是否是第一次加载中
  bool isNoMore = false; // 是否还有更多数据

  List<ObjectModel> objectList = [];
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final serverId = PluginRuntimeService.to.server!.id;

  String keyword = '';
  String get id => widget.id;
  ObjectModel? get object => widget.object;

  /// 获取分页数量
  int get pageSize {
    if (object != null &&
        object!.options != null &&
        object!.options!.pageSize != null) return object!.options!.pageSize!;

    return PluginRuntimeService.to.pluginConfig.pageSize ?? 20;
  }

  @override
  void initState() {
    super.initState();

    // Keyword initialize
    if (widget.keyword.isNotEmpty) {
      keyword = widget.keyword;
      searchController.text = keyword;
    }

    // 监听滚动位置
    scrollController.addListener(() async {
      double distance = scrollController.position.maxScrollExtent -
          scrollController.position.pixels;

      // 距离不够一屏的时候加载下一页
      if (distance < Get.height) {
        if (!isLoading && !isNoMore) await _loadMoreData();
      }
    });

    _initialize(); // 初始化数据
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // 初始化数据
  void _initialize() async {
    await _loadMoreData();
    setState(() {
      isFirstLoading = false;
    });
  }

  // 加载更多数据
  Future<void> _loadMoreData() async {
    setState(() {
      isLoading = true;
    });

    // 获取数据
    List<ObjectModel> _objectList = [];
    if (widget.history && keyword.isEmpty) {
      final _history = await DatabaseService.to.database.historyDao
          .findHistoryByServerId(serverId, pageSize, offset);

      // Convert json to ObjectModel
      _objectList = _history
          .map((h) => ObjectModel.fromJson(json.decode(h.data)))
          .toList();
    } else {
      _objectList = keyword.isNotEmpty
          ? await PluginRuntimeService.to
              .search(object, keyword, offset: offset, limit: pageSize)
          : await PluginRuntimeService.to
              .list(object, offset: offset, limit: pageSize);
    }

    // 过滤非图片数据
    _objectList = _objectList
        .where((o) =>
            PreviewHelper.isImage(o.name ?? '') || o.type == ObjectType.IMAGE)
        .toList();

    objectList.addAll(_objectList);
    offset += pageSize;

    // 如果没有数据，说明没有更多数据了
    if (_objectList.length < pageSize) isNoMore = true;
    isLoading = false;

    CommonUtils.logger.d('数据加载完成, 已加载 ${objectList.length} 条数据');
    setState(() {});
  }

  // 下拉刷新
  Future<void> _refresh() async {
    setState(() {
      objectList.clear();
      offset = 0;
      isNoMore = false;
    });
    await _loadMoreData();
  }

  /// Loading
  Widget _buildLoading() {
    return Center(child: CupertinoActivityIndicator());
  }

  /// EmptyData
  Widget _buildEmptyData() {
    return Column(
      children: [
        SizedBox(height: 500.h),
        Icon(FontAwesomeIcons.solidFile, size: 170.r, color: Colors.grey),
        SizedBox(height: 20.h),
        Text('未查询到数据', style: Get.textTheme.bodyMedium),
      ],
    );
  }

  // 图片瀑布流
  Widget _buildGridView() {
    if (isFirstLoading) return _buildLoading();
    if (objectList.isEmpty && !isLoading) return _buildEmptyData();

    // 是否是横屏
    final isLandscape =
        MediaQuery.of(Get.context!).orientation == Orientation.landscape;

    return MasonryGridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: isLandscape ? 5 : (CommonUtils.isPad ? 3 : 2),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      itemCount: objectList.length,
      itemBuilder: (context, index) {
        final item = objectList[index];
        return FrameSeparateWidget(
          index: index,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ObjectHelper.click(
              object: item,
              type: item.type ?? ObjectType.UNKNOWN,
              objects: objectList,
            ),
            child: ImageLayoutItem(object: item, index: index),
          ),
        );
      },
    );
  }

  Widget _buildScrollView() {
    return SingleChildScrollView(
      controller: scrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Container(
        constraints: BoxConstraints(minHeight: Get.height),
        padding:
            EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 20 : 35.w),
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 5 : 15.w)
                      .copyWith(bottom: 25.h),
              child: CupertinoSearchTextField(
                controller: searchController,
                placeholder: '搜索',
                placeholderStyle: TextStyle(
                  fontSize: 15,
                  color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
                style: TextStyle(fontSize: 18),
                onSubmitted: (String value) {
                  keyword = value;
                  widget.detailController.keyword.value = value;
                  _refresh();
                },
                onSuffixTap: () {
                  keyword = '';
                  widget.detailController.keyword.value = '';
                  searchController.clear();
                  _refresh();
                },
              ),
            ),
            SizeCacheWidget(child: _buildGridView()),
            if (isLoading && !isFirstLoading) _buildLoading(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await HapticFeedback.selectionClick();
        await Future.delayed(Duration(seconds: 1));
        _refresh();
      },
      child: _buildScrollView(),
    );
  }
}
