import 'package:chat_end_to_end/encryption.dart';
import 'package:chat_end_to_end/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'message.dart';

class ChatScreen extends StatefulWidget {
  String email;
  ChatScreen({required this.email});
  @override
  _ChatScreenState createState() => _ChatScreenState(email: email);
}

class _ChatScreenState extends State<ChatScreen> {
  String email;
  _ChatScreenState({required this.email});

  final fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController message = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Screen',
        ),
        actions: [
          MaterialButton(
              onPressed: () {
                _auth.signOut().whenComplete(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                });
              },
              child: const Icon(
                Icons.logout,
              )
              // const Text(
              //   "Log Out",
              //   style: TextStyle(
              //     fontSize: 20,
              //   ),
              // ),
              ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.79,
              child: messages(
                email: email,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(5),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: TextFormField(
                        maxLines: null,
                        controller: message,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'message',
                          enabled: true,
                          contentPadding: EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        onSaved: (value) {
                          message.text = value!;
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.image),
                ),
                IconButton(
                  onPressed: () {
                    if (message.text.isNotEmpty) {
                      var plainText, encryptionText;
                      plainText = message.text.trim();
                      encryptionText = Encryption.encrypt(plainText);
                      fireStore.collection('Messages').doc().set({
                        'message': encryptionText,
                        'time': DateTime.now(),
                        'email': email,
                      });

                      message.clear();
                    }
                  },
                  icon: const Icon(Icons.send_sharp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
