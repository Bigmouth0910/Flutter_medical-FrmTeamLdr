import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  AsyncCallback resumeCallBack;
  AsyncCallback suspendingCallBack;

  LifecycleEventHandler(
      {required this.resumeCallBack, required this.suspendingCallBack});

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   print('1111111111111111111111111111111111111111');
  //   print(state);
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       print('resumed');
  //       if (resumeCallBack != null) {
  //         await resumeCallBack();
  //       }
  //       break;
  //     case AppLifecycleState.inactive:
  //       print('inactive');
  //       // await inactiveCallBack();
  //       break;
  //     case AppLifecycleState.paused:
  //       print('paused');
  //       // await pausedCallBack();
  //       break;
  //     case AppLifecycleState.detached:
  //       print('detached');
  //       if (suspendingCallBack != null) {
  //         await suspendingCallBack();
  //       }
  //       break;
  //   }
  // }
}
