import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_organizer/Screen/homescreen.dart';
import 'package:event_organizer/Screen/login.dart';
import 'package:event_organizer/Screen/multihost.dart';
import 'package:event_organizer/model/UserModel.dart';
import 'package:event_organizer/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class hosted extends StatefulWidget {
  const hosted({Key? key}) : super(key: key);

  @override
  State<hosted> createState() => _hostedState();
}

class _hostedState extends State<hosted> {
  @override
  final Stream<QuerySnapshot> party =
      FirebaseFirestore.instance.collection('party').snapshots();

  User? user = FirebaseAuth.instance.currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel loggedInUser = UserModel();

  int _currentIndex = 0;

  _onTap() async {
    if (_currentIndex == 4) {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const loginscreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => _childern[_currentIndex]));
    }
  }

  final List<Widget> _childern = [
    const HomeScreen(),
    const user_profile(),
    const upload_Details(),
    const hosted()
  ];

  String? image;
  String? name;

  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("user")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      name = loggedInUser.firstName;
      print(name);

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                  stream: party,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something");
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('waiting');
                    }
                    final data = snapshot.requireData;
                    int a = data.size;
                    return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        image = data.docs[index]['image'];
                        if (user!.uid != data.docs[index]['uid']) {
                          return Text('no party hosted');
                        }
                        return Card(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Image.network(
                                image.toString(),
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.event_available),
                                    Text(
                                      "Event Name : ${data.docs[index]['party_name']}",
                                    ),
                                    Text(
                                        "Event Date : ${data.docs[index]['date']}"),
                                    Text(
                                        "Event Time : ${data.docs[index]['time']}"),
                                    Text(
                                        "Event Location : ${data.docs[index]['location']}")
                                  ]),
                              SizedBox(
                                height: 10,
                              )
                            ]));
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_outlined),
              label: "Add Event"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Lists"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _onTap();
        },
      ),
    );
  }
}
