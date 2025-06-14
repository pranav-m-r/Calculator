import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/themedata.dart' as globals;

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final String? userID = FirebaseAuth.instance.currentUser!.email;

  void clearHistory() {
    FirebaseFirestore.instance.collection(userID!).get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: globals.appBarColor,
        title: const Text('History'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                clearHistory();
              }),
        ],
      ),
      body: Container(
        color: globals.backgroundColor,
        width: screenWidth,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(userID!)
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  return Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: GestureDetector(
                      onTap: () {
                        globals.lastCalc = doc['calc'];
                        globals.ans = doc['calc'].split(' = ')[1];
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: globals.textColor, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(doc['calc'],
                              style: const TextStyle(fontSize: 20)),
                          textColor: globals.textColor,
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: globals.textColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
