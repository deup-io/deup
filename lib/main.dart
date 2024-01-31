import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:deup/global.dart';
import 'package:deup/themes.dart';
import 'package:deup/components/index.dart';
import 'package:deup/routes/app_pages.dart';
import 'package:deup/pages/splash/splash_view.dart';
import 'package:deup/langs/translation_service.dart';
import 'package:deup/pages/splash/splash_binding.dart';

void main() => Global.init().then((e) => runApp(Phoenix(child: DeupApp())));

class DeupApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(1080, 1920),
      builder: (context, child) => GetMaterialApp(
        title: 'Deup',
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeMode.light,
        home: SplashPage(),
        initialBinding: SplashBinding(),
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        unknownRoute: AppPages.unknownRoute,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: FlutterSmartDialog.init(
              toastBuilder: (String msg) => ToastComponent(message: msg),
            )(context, child),
          );
        },
        translations: TranslationService(),
        locale: TranslationService.locale,
        fallbackLocale: TranslationService.fallbackLocale,
      ),
    );
  }
}
