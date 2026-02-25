import 'package:flutter/material.dart';
import 'package:zdravi_pod_kontrolou/core/app_settings.dart';

class AppScope extends InheritedNotifier<AppSettings> {
  const AppScope({
    super.key,
    required AppSettings settings,
    required Widget child,
  }) : super(notifier: settings, child: child);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found. Wrap your app with AppScope.');
    return scope!.notifier!;
  }
}
