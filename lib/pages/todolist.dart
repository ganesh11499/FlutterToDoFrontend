import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Product {
  final String title;
  final String description;
  final String userId;
  final String id;

  Product(
      {required this.title,
      required this.description,
      required this.userId,
      required this.id});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Product(title: $title)';
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  String? email;
  String? userId;
  List<Product> todoListData = [];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }
  

  Future<void> getToDoList(String userId) async {
    final url = Uri.parse('http://172.25.160.1:3500/getToDoList/$userId');

    try {
      final response = await http.get(url); // Send the GET request

      if (response.statusCode == 200) {
        // Decode the JSON response body
        final List<dynamic> productData = json.decode(response.body);

        setState(() {
          todoListData =
              productData.map((json) => Product.fromJson(json)).toList();
        });
      } else {
        todoListData = [];
      }
    } catch (e) {
      todoListData = [];
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      userId = prefs.getString('userId');
    });
    if (userId != null) {
      await getToDoList(userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              scaffoldKey.currentState!
                  .openDrawer(); // Open drawer on menu icon press
            },
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'ToDo App',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons
                    .exit_to_app), // Use Icons.exit_to_app for the logout icon
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () async {
                  // Close the drawer (optional)
                  Navigator.pop(context);

                  // Navigate to the login page
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); 
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                searchBox(),
                _buildButtonBar(context, userId, getToDoList),
                todoList(todoListData, getToDoList),
              ],
            ),
          ),
        ));
  }
}

//ToDo item list

Widget todoList(List<Product> todoListData, Function getToDoList) {
  Future<void> deleteTodo(String id, String userId) async {
    final url = Uri.parse('http://172.25.160.1:3500/deleteToDo/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'ToDo deleted successfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
          webPosition: 'center',
        );
        await getToDoList(userId);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to delete ToDo',
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
        msg: 'Failed to delete ToDo',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
        webPosition: 'center',
      );
    }
  }

  return Container(
    margin: EdgeInsets.only(bottom: 20),
    child: Column(
      children: todoListData.map((product) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () {
              // Define your onTap action here
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            tileColor: Colors.white,
            textColor: Colors.white,
            leading: Icon(
              Icons.check_box,
              color: Colors.lightBlue,
            ),
            title: Text(
              product.title,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 177, 17, 5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Colors.white,
                onPressed: () {
                  // Define your delete action here
                  deleteTodo(product.id, product.userId);
                },
                icon: Icon(Icons.delete),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget searchBox() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: TextField(
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 16,
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.black))),
  );
}

//Add buttom and All list
Widget _buildButtonBar(BuildContext context, userId, getToDoList) {
  return Container(
    margin: const EdgeInsets.only(top: 20), // Add top margin
    child: AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "ToDo List",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(50), // Circular border radius
                ),
                // Remove shadow if needed
              ),
              onPressed: () {
                //Show add todo list pop up screen
                _showPopup(context, userId, getToDoList);
              },
              child: const Icon(Icons.add, color: Colors.black), // "+" icon
            ),
          ),
        ],
      ),
    ),
  );
}

void _showPopup(BuildContext context, userId, Function getToDoList) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController titleController = TextEditingController();
      TextEditingController descriptionController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      //Add todo api
      Future<void> addTodo(context, String title, String description) async {
        const url = 'http://172.25.160.1:3500/createToDo';

        try {
          final Map<String, dynamic> body = {
            'userId': userId,
            'title': title,
            'description': description
          };

          final response = await http.post(Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode(body));

          if (response.statusCode == 200) {
            Fluttertoast.showToast(
              msg: 'ToDo created successfully',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
              webPosition: 'center',
            );

            // Call the getToDoList function after adding the todo
            await getToDoList(userId);

            Navigator.of(context).pop();
          } else {
            Fluttertoast.showToast(
              msg: 'Failed to create todo',
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
            msg: 'Failed to create todo',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
            webPosition: 'center',
          );
        }
      }

      return AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Add Details",
          style: TextStyle(color: Colors.white),
        ),
        content: Form(
          key: formKey, // Associate the form key with the Form widget
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: descriptionController,
                  maxLines: 3, // Multiline input
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  addTodo(context, titleController.text,
                      descriptionController.text);
                  // Navigator.of(context).pop();
                }
              },
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ])
        ],
      );
    },
  );
}

// AppBar _buildAppBar(BuildContext context) {
//   final GlobalKey<ScaffoldState> scaffoldKey =
//       GlobalKey<ScaffoldState>(); 
      
//       // Scaffold key
//   return AppBar(
//     backgroundColor: Colors.black,
//     elevation: 0,
//     leading: IconButton(
//       onPressed: () {
//         scaffoldKey.currentState!.openDrawer();
//       },
//       icon: Icon(
//         Icons.menu,
//         color: Colors.white,
//       ),
//     ),
//     drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             // You can add your logo or other elements here
//             DrawerHeader(
//               child: Text(
//                 'Welcome',
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//               ),
//             ),
//             ListTile(
//               title: Text('Logout'),
//               onTap: () {
//                  Navigator.pushNamed(context, '/login'); // Call logout function
//               },
//             ),
//           ],
//         ),
//       ),
     
//   );
// }
