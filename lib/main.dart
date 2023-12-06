import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:ui_project_hochiminh_museum/app.dart';
import 'package:ui_project_hochiminh_museum/dependency_injection.dart';
import 'package:ui_project_hochiminh_museum/features/notifications/local_notificaitons.dart';
import 'package:ui_project_hochiminh_museum/features/notifications/notifiactions_model.dart';
import 'package:ui_project_hochiminh_museum/features/notifications/notifications_controller.dart';
import 'package:ui_project_hochiminh_museum/firebase_options.dart';
import 'package:ui_project_hochiminh_museum/repository/authentication_repository/authentication_repository.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalNotification.initialize();

  //saves app config
  await GetStorage.init('app-setting-configs');
  await GetStorage.init("app-notifications");

  FirebaseMessaging.onMessage.listen((message) {
    handlePushNotification(message);
  });

  final initList = {
    'TinTucSuKien': [
      'HDBaoTang',
      'HDHeThongCacBT_DTLuuNiemHCM',
      'HDNganhDSVH',
      'HDBaoTangTrenTG',
    ],
    'NghienCuu': [
      'NghienCuuHCM',
      'ChuyenKeHCM',
      'AnPhamHCM',
      'BoSuuTap',
      'HienVatKeChuyen',
      'HDKhoaHoc',
      'CongBoKH',
    ],
    'GiaoDuc': [
      'HocTapTheoTamGuongHCM',
      'KeChuyenHCM',
      'NhungTamGuong',
      'PhongKhamPha',
      'BoiDuongNghiepVu',
      'CacHoatDongKhac',
    ]
  };

  for (var i in initList.keys) {
    await GetStorage.init(i);
  }

  //cache news

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then(
    (value) => Get.put(
      AuthenticationRepository(),
    ),
  );
  runApp(const MyApp());
  DependencyInjection.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return App();
  }
}

void handlePushNotification(message) async {
  List<NotificationsMessageModel> listNotifications =
      GetStorage("app-notifications").read("notifications") ?? [];
  String title = message.notification!.title as String;
  String body = message.notification!.body as String;
  dynamic data = message.data;

  print(listNotifications);

  listNotifications.insert(
      0,
      NotificationsMessageModel(
          title: title, body: body, data: data, timestamp: DateTime.now()));
  await GetStorage("app-notifications")
      .write("notifications", listNotifications);

  print(listNotifications);

  final controller = Get.put(NotificationsController());
  // controller.listNotification = listNotifications;
  LocalNotification.showNotification(message);
}
