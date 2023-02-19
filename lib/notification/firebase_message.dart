// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nigh/notification/local_notification.dart';

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
    await checkPermission();

    // proceed if notification is allowed
    if (!ref.watch(disabledNotification)) {
      // set firebase listener
      messageListener();
    }
  }

  Future<void> checkPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus.name == AuthorizationStatus.authorized.name) {
      ref.read(disabledNotification.notifier).state = false;

      await firebaseMessaging.getToken().then((value) {
        print('getToken fcmToken $value');
      }).catchError((err) {
        print('getToken err = $err');
      });

      // init flutter_local_notification methods
      ref.read(localNotificationProvider).init();
    }
  }

  Future<void> messageListener() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ref.read(localNotificationProvider).showNotification(message);
    });
  }
}
