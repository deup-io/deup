import 'dart:convert';

import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:deup/helper/index.dart';
import 'package:deup/models/index.dart';
import 'package:deup/common/index.dart';
import 'package:deup/services/index.dart';
import 'package:deup/constants/index.dart';
import 'package:deup/pages/detail/detail_controller.dart';
import 'package:deup/pages/detail/layouts/poster_layout/poster_layout_item.dart';

class PosterLayout extends StatefulWidget {
  final String id;
  final bool history;
  final String keyword;
  final ObjectModel? object;
  final DetailController detailController;

  const PosterLayout({
    Key? key,
    required this.id,
    required this.object,
    required this.history,
    required this.keyword,
    required this.detailController,
  }) : super(key: key);

  @override
  _PosterLayoutState createState() => _PosterLayoutState();
}

class _PosterLayoutState extends State<PosterLayout> {
  final serverId = PluginRuntimeService.to.server!.id;
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final PagingController<int, ObjectModel> pagingController =
      PagingController(firstPageKey: 0);

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
    // Keyword initialize
    if (widget.keyword.isNotEmpty) {
      keyword = widget.keyword;
      searchController.text = keyword;
    }

    // PagingController
    pagingController.addPageRequestListener((offset) {
      getFileListData(offset);
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// 获取文件列表
  ///
  /// [offset] 当前游标
  Future<void> getFileListData(int offset) async {
    try {
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
      // 过滤掉没有海报的数据
      _objectList = _objectList
          .where(
              (element) => element.poster != null && element.poster!.isNotEmpty)
          .toList();

      final isLastPage = _objectList.length < pageSize;
      isLastPage
          ? pagingController.appendLastPage(_objectList)
          : pagingController.appendPage(
              _objectList, offset + _objectList.length);
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  Widget _buildSliverGrid() {
    return PagedSliverGrid<int, ObjectModel>(
      pagingController: pagingController,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 130,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      builderDelegate: PagedChildBuilderDelegate<ObjectModel>(
        animateTransitions: false,
        noItemsFoundIndicatorBuilder: (context) => _buildEmptyData(),
        firstPageProgressIndicatorBuilder: (context) => _buildLoading(),
        newPageProgressIndicatorBuilder: (context) => _buildLoading(),
        itemBuilder: (context, item, index) {
          return FrameSeparateWidget(
            index: index,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ObjectHelper.click(
                object: item,
                type: item.type ?? ObjectType.UNKNOWN,
                objects: pagingController.itemList ?? [],
              ),
              child: PosterLayoutItem(object: item),
            ),
          );
        },
      ),
    );
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

  // ScrollView
  // Replace to [NestedScrollView]
  Widget _buildCustomScrollView() {
    return CustomScrollView(
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: scrollController,
      slivers: <Widget>[
        GetPlatform.isIOS
            ? CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 1));
                  pagingController.refresh();
                },
              )
            : SliverToBoxAdapter(),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 25 : 50.w)
                  .copyWith(bottom: 30.h),
          sliver: SliverToBoxAdapter(
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
                pagingController.refresh();
              },
              onSuffixTap: () {
                keyword = '';
                widget.detailController.keyword.value = '';
                searchController.clear();
                pagingController.refresh();
              },
            ),
          ),
        ),
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: CommonUtils.isPad ? 20 : 30.w)
                  .copyWith(bottom: 50.h),
          sliver: SizeCacheWidget(child: _buildSliverGrid()),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetPlatform.isAndroid
        ? RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
              pagingController.refresh();
            },
            child: _buildCustomScrollView(),
          )
        : _buildCustomScrollView();
  }
}
