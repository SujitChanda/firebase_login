import 'package:bengaliallinone/constants.dart';
import 'package:bengaliallinone/provider/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bengaliallinone/route.dart';
import 'package:bengaliallinone/screens/splash_screen.dart';
import 'package:bengaliallinone/utility/size_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  prefs = await SharedPreferences.getInstance();
  quizAttemptLimit = await SharedPreferences.getInstance();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: kSecondaryColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return MultiProvider(
      providers: [
        
      
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
       
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        
       
        home: LayoutBuilder(builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizeConfig().init(constraints, orientation);

              return MediaQuery.of(context).size.shortestSide > 600
                  ? SplashScreen()
                  : SplashScreen();
            },
          );
        }),
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        builder: EasyLoading.init(),
      ),
    );
  }
}
