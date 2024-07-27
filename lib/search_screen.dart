import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "your_api_key",
      authDomain: "your_auth_domain",
      projectId: "your_project_id",
      storageBucket: "your_storage_bucket",
      messagingSenderId: "your_messaging_sender_id",
      appId: "your_app_id",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchScreen(),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  void fetchUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      filteredUsers = users;
    });
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> dummyListData = users.where((item) {
        return item['name'].toLowerCase().contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredUsers = dummyListData;
      });
    } else {
      setState(() {
        filteredUsers = users;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search by name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredUsers[index]['name']),
                  subtitle: Text(filteredUsers[index]['email']),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          searchController.clear();
          setState(() {
            filteredUsers = users;
          });
        },
        child: Icon(Icons.clear),
      ),
    );
  }
}
