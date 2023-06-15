import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/main_app.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_kit_plugin/user_defaults/user_defaults.dart';
import 'package:widget_kit_plugin/widget_kit/widget_kit.dart';
import 'package:window_manager/window_manager.dart';

class WindowManager extends StatefulWidget {
  const WindowManager({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<WindowManager> createState() => _WindowManagerState();
}

class _WindowManagerState extends State<WindowManager> with WindowListener {
  @override
  void initState() {
    if (isDesktopOS()) {
      windowManager.addListener(this);
      _initManager();
    }

    if (isApple()) {
      _initWidgets();
    }

    super.initState();
  }

  void _initManager() async {
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  void _initWidgets() async {
    //print("## SET DATA");
    //await UserDefaults.setString('widgetData', 'hello', 'group.com.invoiceninja.app');
    //await WidgetKit.reloadAllTimelines();
  }

  @override
  void onWindowResize() async {
    if (!isDesktopOS()) {
      return;
    }

    final size = await windowManager.getSize();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(kSharedPrefWidth, size.width);
    prefs.setDouble(kSharedPrefHeight, size.height);
  }

  @override
  void onWindowClose() async {
    if (!isDesktopOS()) {
      return;
    }

    final store = StoreProvider.of<AppState>(navigatorKey.currentContext);

    if (await windowManager.isPreventClose()) {
      checkForChanges(
        store: store,
        callback: () async {
          await windowManager.destroy();
        },
      );
    }
  }

  @override
  void dispose() {
    if (isDesktopOS()) {
      windowManager.removeListener(this);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class WidgetData {
  WidgetData({this.url, this.tokens});

  WidgetData.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        tokens = json['tokens'];

  final String url;
  final Map<String, String> tokens;
  
  Map<String, dynamic> toJson() => <String, dynamic>{
        'tokens': tokens,
        'url': url,
      };
}
