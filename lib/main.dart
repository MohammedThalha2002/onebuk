import 'package:flutter/material.dart';
import 'package:onebuk/pages/notes_page.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesApp(),
      theme: ThemeData(),
    );
  }
}