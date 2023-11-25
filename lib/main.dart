
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'screens/onboding/onboding_screen.dart';



FlutterLocalNotificationsPlugin notificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
 

  AndroidInitializationSettings androidsettings=
  AndroidInitializationSettings("@mipmap/ic_launcher");
   
   DarwinInitializationSettings iosSettings =
   DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestCriticalPermission: true,
    requestSoundPermission: true,
   );

   InitializationSettings initializationSettings =
   InitializationSettings
   (
    android: androidsettings,
    iOS: iosSettings
   );


  bool? initialized = await notificationsPlugin.initialize(initializationSettings);
  
  if (initialized != null && initialized) {
    print("Notifications: true");
  } else {
    print("Notifications: false");
  }

  runApp(const MyApp());
}
final navigatorKey=GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   
    return MaterialApp(
       debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,

      title: 'GEOSENSE',
      theme: ThemeData(
        
        
        scaffoldBackgroundColor: Color(0xFFEEF1F8),
        primarySwatch: Colors.blue,
        fontFamily: "Intel",
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          errorStyle: TextStyle(height: 0),),
       
    
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      
    
        
        
        
      ),
      
      
      home:OnbodingScreen(),
    );
  }
}

const defaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(16)),
  borderSide: BorderSide(
    color: Color(0xFFDEE3F2),
    width: 1,
  ),
);
