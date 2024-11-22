import 'package:flutter/material.dart';
import 'package:todofrontend/pages/loginpage.dart';
import 'package:todofrontend/pages/register.dart';
import 'package:todofrontend/pages/todolist.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (context) => ToDoList());
        case '/login':
          return MaterialPageRoute(builder: (context) => LoginPage());
        case '/register':
          return MaterialPageRoute(builder: (context) => Registerpage());
        default:
          return MaterialPageRoute(builder: (context) => LoginPage());
      }
    },
  ));
}
