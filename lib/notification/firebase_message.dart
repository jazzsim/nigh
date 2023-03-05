// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/notification/local_notification.dart';
import 'package:nigh/screens/user/user_controller.dart';

final disabledNotification = StateProvider<bool>((ref) => true);

final firebaseMessageProvider = Provider<FirebaseMessage>((ref) {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  return FirebaseMessage(ref, messaging);
});

class FirebaseMessage {
  final ProviderRef<FirebaseMessage> ref;
  final FirebaseMessaging firebaseMessaging;
  FirebaseMessage(this.ref, this.firebaseMessaging) : super();

  Future<void> initFirebase() async {
    print('init firebase');
    // check permission everytime
    bool allowNotification = await checkPermission();

    // if notification allowed
    if (allowNotification) {
      await firebaseMessaging.getToken().then((value) {
        print('getToken fcmToken $value');
        // store token
        ref.read(userNotifierProvider.notifier).storeFcmToken(value ?? '').catchError((err) {});
      }).catchError((err) {
        print('getToken err = $err');
      });

      // init flutter_local_notification methods
      ref.read(localNotificationProvider).init();

      // set firebase listener
      messageListener();
    }
  }

  Future<bool> checkPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings.authorizationStatus.name == AuthorizationStatus.authorized.name;
  }

  Future<void> messageListener() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ref.read(localNotificationProvider).showNotification(message);
    });
  }
}
