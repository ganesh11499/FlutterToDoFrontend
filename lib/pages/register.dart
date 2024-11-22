import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  // void resisterUser async() {

  @override
  RegisterpageState createState() => RegisterpageState();
}

class RegisterpageState extends State<Registerpage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String ? email;
  String ? userId;




  //Register user api
  Future<void> registerUser(context, String email, String password) async {
    const url = 'http://172.25.160.1:3500/registerUser';

    try {
      final Map<String, dynamic> body = {'email': email, 'password': password};

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "User registered successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          webPosition: "center",
          fontSize: 16.0,
        );

        Navigator.pushNamed(context, '/login');
      } else {
        Fluttertoast.showToast(
          msg: responseData['message'] ?? "Failed To Register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          webPosition: "center",
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Internal Server Error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        webPosition: "center",
        fontSize: 16.0,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

             //Register Name
             Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                 'Register',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                
              ],
            ),

            const SizedBox(height: 20,),//Space between the fields

            //Email field
            SizedBox(
              width: 350,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Additional validation for email format (optional)
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
                    prefixIcon: const Icon(Icons.email, color: Colors.white)),
              ),
            ),

           

            const SizedBox(height: 20), //Space between the fields

            //Password textfield
            SizedBox(
              width: 350,
              child: TextFormField(
                style: TextStyle(color: Colors.white),
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: true,
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
                    prefixIcon: const Icon(Icons.lock, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 20), //Space between fields

            //Register button
            SizedBox(
              width: 350,
              height: 40,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      registerUser(
                        context,
                        emailController.text,
                        passwordController.text,
                      );
                    }
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  )),
            ),

            const SizedBox(height: 20), //Space between fields

            //Already Have an account Sign In
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                InkWell(
                  onTap: () {
                    // Navigate to login page
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    ' Sign In',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          Colors.yellow, // Optional for a link style
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
