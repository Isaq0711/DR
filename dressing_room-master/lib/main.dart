import 'package:dressing_room/providers/bottton_nav_controller.dart';
import 'package:dressing_room/providers/isshop_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dressing_room/providers/user_provider.dart';
import 'package:dressing_room/responsive/mobile_screen_layout.dart';
import 'package:dressing_room/responsive/responsive_layout.dart';
import 'package:dressing_room/screens/login_screen.dart';
import 'package:dressing_room/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:dressing_room/screens/handle_outside_media.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC19GhITjqB5vUIJvHRB4cxnfCTHyX02vU",
        appId: "1:755117795647:web:63a2fdb492a46fb9f0cb8a",
        messagingSenderId: "755117795647",
        projectId: "tentativa1-56553",
        storageBucket: "tentativa1-56553.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    _intentSub = ReceiveSharingIntent.getMediaStream().listen(
        (List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        Navigator.pushNamed(context, '/handleoutsidemedia');
      }
    }, onError: (err) {
      print("getMediaStream error: $err");
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (_) => BottonNavController()),
        ChangeNotifierProvider(create: (_) => ZoomProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => CartCounterProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        rebuildFactor: (old, data) => true,
        useInheritedMediaQuery: true,
        builder: (context, widget) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DressRoom',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppTheme.cinza,
            ),
            routes: {
              '/handleoutsidemedia': (context) => HandleOutsideMedia(),
              '/login': (context) => LoginScreen(),
            },
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    ReceiveSharingIntent.getInitialMedia()
                        .then((List<SharedMediaFile> value) {
                      if (value.isNotEmpty) {
                        Navigator.pushNamed(context, '/handleoutsidemedia');
                      }
                    });
                    return const ResponsiveLayout(
                      mobileScreenLayout: MobileScreenLayout(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  } else {
                    // No user logged in, navigate to login screen
                    Future.delayed(Duration.zero, () {
                      Navigator.pushReplacementNamed(context, '/login');
                    });
                    return const SizedBox(); // Placeholder widget until navigation completes
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
