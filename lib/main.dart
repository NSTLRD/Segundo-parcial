
/*
* Author: starling diaz
* Matricula: 20210416
* */
import 'package:flutter/material.dart';
import 'DB/Database.dart';
import 'Views/screenInformation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData.dark(), // Aplica el tema oscuro
      home: Scaffold(
        body: HomeScreen(),
      ),
    );
  }
}
