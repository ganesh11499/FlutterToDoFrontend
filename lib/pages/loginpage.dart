import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //Login user api integration
  Future<void> loginUser(context, email, password) async {
    const url ='http://172.25.160.1:3500/login';

    try {
      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Login successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
          webPosition: 'center',
        );

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', responseData['email']);
        await prefs.setString('userId', responseData['id']);
        await prefs.setString('token', responseData['token']);

        //Navigate to homepage
        Navigator.pushNamed(context, '/');
      }else {
         Fluttertoast.showToast(
          msg: 'Failed to login',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
          webPosition: 'center',
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Failed to login',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
          webPosition: 'center',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Vertically center the fields
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login',
                      style: TextStyle(fontSize: 25, color: Colors.white)),
                ],
              ),
              const SizedBox(
                height: 20,
              ), //Space between the fields
              // Email TextField
              SizedBox(
                width: 350, // Set the width of the input field
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20), // Space between fields

              // Password TextField
              SizedBox(
                width: 350, // Set the width of the input field
                child: TextFormField(
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ), //Space between fields

              //Login button
              SizedBox(
                width: 350,
                height: 40,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        loginUser(
                          context,
                          emailController.text,
                          passwordController.text,
                        );
                      }
                    },
                    child: Text("Login",
                        style: TextStyle(
                          color: Colors.white,
                        ))),
              ),

              //Don't have an account Sing UP here
              const SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      //Navigate to register page
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.yellow),
                    ),
                  ),
                ],
              ) //space between the fields
            ],
          ),
        ),
      ),
    );
  }
}
