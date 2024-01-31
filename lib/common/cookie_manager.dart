import 'dart:convert';

import 'package:deup/models/index.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Cookie 设置
class Cookie {
  CookieManager cookieManager = CookieManager.instance();

  /// 获取 Cookie
  ///
  /// [url] 需要获取的 url
  /// [name] 需要获取的 name
  Future<dynamic> get(String url, String? name) async {
    if (name == null || name.isEmpty) {
      return json.encode(await cookieManager.getCookies(url: WebUri(url)));
    }

    return json
        .encode(await cookieManager.getCookie(url: WebUri(url), name: name));
  }

  /// 设置 Cookie
  ///
  /// [url] url
  /// [name] name
  /// [value] value
  /// [options] 设置选项
  Future<bool> set(
      String url, String name, String value, CookieOptionsModel options) async {
    return await cookieManager.setCookie(
      url: WebUri(url),
      name: name,
      value: value,
      path: options.path ?? '/',
      domain: options.domain,
      expiresDate: options.expiresDate,
      maxAge: options.maxAge,
      isSecure: options.isSecure,
      isHttpOnly: options.isHttpOnly,
      sameSite: options.sameSite != null
          ? HTTPCookieSameSitePolicy.fromValue(options.sameSite!.toLowerCase())
          : null,
    );
  }
}
