import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:schedule_project_with_gemini/screen/home/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //initialize hive
  await Hive.initFlutter();
  //box
  await Hive.openBox('searchHistory');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen()
    );
  }
}
