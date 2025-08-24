import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/auth_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/user_controller.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home_screen.dart';
import 'views/chat/create_group_screen.dart';
import 'views/chat/chat_screen.dart';
import 'views/users_screen.dart'; // Add this import
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize controllers
  Get.put(AuthController());
  Get.put(ChatController());
  Get.put(UserController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) {
          final AuthController authController = Get.find<AuthController>();
          return Obx(() {
            if (authController.currentUser.value != null) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          });
        },
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.register: (context) => RegisterScreen(),
        AppRoutes.home: (context) => HomeScreen(),
        AppRoutes.createGroup: (context) => CreateGroupScreen(),
        '/users': (context) => UsersScreen(), // Add this route
      },
      // Add fallback for unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
      },
    );
  }
}
