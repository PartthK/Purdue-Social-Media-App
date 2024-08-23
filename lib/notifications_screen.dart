import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

class NotificationsScreen extends StatelessWidget {
  final String userId;

  NotificationsScreen({required this.userId});

  Future<void> handleFriendRequest(String requestId, bool accept) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final requestDoc = FirebaseFirestore.instance.collection('users').doc(userId).collection('friendRequests').doc(requestId);

      if (accept) {
        final requestData = await requestDoc.get();
        final fromUser = requestData.data()?['from'];
        if (fromUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'friends': FieldValue.arrayUnion([fromUser]),
          });
          await FirebaseFirestore.instance.collection('users').doc(fromUser).update({
            'friends': FieldValue.arrayUnion([currentUser.email]),
          });
        }
      }

      await requestDoc.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('friendRequests').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('${doc['from']} sent you a friend request', style: TextStyle(fontFamily: 'Montserrat')),
                    subtitle: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            handleFriendRequest(doc.id, true);
                          },
                          child: Text('Accept'),
                        ),
                        TextButton(
                          onPressed: () {
                            handleFriendRequest(doc.id, false);
                          },
                          child: Text('Ignore'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
