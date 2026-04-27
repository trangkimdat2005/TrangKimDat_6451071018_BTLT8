import 'package:flutter/material.dart';
import '../../common/widget/home_screen.dart';
import 'app_initializer.dart' as app_init;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app_init.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BTLT Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
