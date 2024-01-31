import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

import 'package:deup/services/index.dart';
import 'package:deup/pages/webview/webview_controller.dart';

class WebviewPage extends GetView<WebviewController> {
  const WebviewPage({Key? key}) : super(key: key);

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      backgroundColor: Get.theme.colorScheme.background,
      border: Border.all(width: 0, color: Colors.transparent),
      leading: Container(
        width: 300.w,
        child: Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              child: Icon(CupertinoIcons.refresh),
              onPressed: () {
                controller.webViewController?.reload();
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              child: Icon(CupertinoIcons.arrow_left),
              onPressed: () {
                controller.webViewController?.goBack();
              },
            ),
          ],
        ),
      ),
      middle: Text(
        controller.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerRight,
        child: Icon(CupertinoIcons.xmark_circle_fill),
        onPressed: () {
          Get.back();
        },
      ),
    );
  }

  Widget _buildInAppWebView() {
    return InAppWebView(
      key: controller.webViewKey,
      initialUrlRequest: URLRequest(url: WebUri(controller.url)),
      initialSettings: controller.options,
      onWebViewCreated: controller.onWebViewCreated,
      onLoadStart: controller.onLoadStart,
      onLoadStop: controller.onLoadStop,
      onProgressChanged: controller.onProgressChanged,
      onConsoleMessage: controller.onConsoleMessage,
      onReceivedServerTrustAuthRequest: (app, challenge) async {
        return ServerTrustAuthResponse(
          action: ServerTrustAuthResponseAction.PROCEED,
        );
      },
      shouldOverrideUrlLoading: (app, navigationAction) async {
        final uri = navigationAction.request.url!;

        // https://deup.io/plugins/add?url=https%3A%2F%2Fcdn.jsdelivr.net%2Fgh%2Fdeup-io%2Fdeup%2Fmovies-tv.js
        if (uri.host == "deup.io" && uri.path == "/plugins/add") {
          final url = uri.queryParameters["url"];
          if (url != null) DeeplinkService.to.addPlugin(url);
          return NavigationActionPolicy.CANCEL;
        }

        /// 过滤掉不需要跳转的链接
        if (!["http", "https", "file", "chrome", "data", "javascript", "about"]
            .contains(uri.scheme)) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavigationBar(),
      body: BottomBar(
        width: 500.r,
        hideOnScroll: true,
        borderRadius: BorderRadius.circular(500),
        child: SizedBox(),
        body: (context, scrollController) => Stack(
          children: [
            _buildInAppWebView(),
            Obx(
              () => controller.progress.value < 1.0
                  ? LinearProgressIndicator(
                      value: controller.progress.value,
                      backgroundColor: Colors.transparent,
                      minHeight: 2,
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
