import 'dart:developer';
import 'dart:io';

import 'package:bengaliallinone/constants.dart';
import 'package:bengaliallinone/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // description
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationplugin =
    FlutterLocalNotificationsPlugin();

Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  var data = message.data;
  print(message.data);
  String largeIconPath =
      await _downloadAndSaveFile(data['picture'], 'largeIcon');
  String bigPicturePath =
      await _downloadAndSaveFile(data['bigPic'], 'bigPicture');
  final styleInformation = BigPictureStyleInformation(
    FilePathAndroidBitmap(bigPicturePath),
    largeIcon: FilePathAndroidBitmap(largeIconPath),
  );

  AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(
      channel.id, channel.name,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: styleInformation,
      groupKey: channel.groupId);
  NotificationDetails notificationDetailsPlatformSpefics =
      NotificationDetails(android: notificationDetails);
  flutterLocalNotificationplugin.show(data.hashCode, data['title'],
      data['message'], notificationDetailsPlatformSpefics);
  print("foreground Data  ${message.messageId}");
  print(message.data);

  print("Handling a background message : ${message.messageId}");
  print(message.data);
}

FirebaseServices _service = new FirebaseServices();

class FirebaseNotifcation {
  final BuildContext context;

  FirebaseNotifcation({required this.context});

  initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await flutterLocalNotificationplugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    var intializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: intializationSettingsAndroid);

    flutterLocalNotificationplugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      var data = message.data;
      //AndroidNotification? android = message.notification?.android;
      print(message.data);
      String largeIconPath =
          await _downloadAndSaveFile(data['picture'], 'largeIcon');
      String bigPicturePath =
          await _downloadAndSaveFile(data['bigPic'], 'bigPicture');
      final styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
      );

      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name,
              importance: Importance.max,
              styleInformation: styleInformation,
              priority: Priority.high,
              groupKey: channel.groupId);
      NotificationDetails notificationDetailsPlatformSpefics =
          NotificationDetails(android: notificationDetails);
      flutterLocalNotificationplugin.show(data.hashCode, data['title'],
          data['message'], notificationDetailsPlatformSpefics);
      print("foreground Data  ${message.messageId}");
      print(message.data);

      List<ActiveNotification>? activeNotifications =
          await flutterLocalNotificationplugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.getActiveNotifications();
      if (activeNotifications!.length > 0) {
        List<String> lines =
            activeNotifications.map((e) => e.title.toString()).toList();
        InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
            lines,
            contentTitle: "${activeNotifications.length - 1} messages",
            summaryText: "${activeNotifications.length - 1} messages");
        AndroidNotificationDetails groupNotificationDetails =
            AndroidNotificationDetails(
          channel.id,
          channel.name,
          styleInformation: inboxStyleInformation,
          setAsGroupSummary: true,
        );

        // NotificationDetails groupNotificationDetailsPlatformSpefics =
        //     NotificationDetails(android: groupNotificationDetails);
        // await flutterLocalNotificationplugin.show(
        //     0, '', '', groupNotificationDetailsPlatformSpefics);
      }
    });
  }

  getToken() async {
    await FirebaseMessaging.instance.getToken().then((val) {
      if (prefs!.getString('FCMToken') != val) {
        print('FB Token from Server: ' + val!);
        _service.updateToken({
          'id': FirebaseAuth.instance.currentUser!.uid,
          'token': val,
        });
        prefs!.setString('FCMToken', val);
      } else {
        print('FB Token from SF: ' + prefs!.getString('FCMToken').toString());
      }
    });
    // print(token);
  }

  subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    log("Subscribed to  $topic");
  }
}
