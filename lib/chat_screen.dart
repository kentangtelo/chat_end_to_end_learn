import 'dart:convert';

import 'package:chat_end_to_end/encryption.dart';
import 'package:chat_end_to_end/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'message.dart';

class ChatScreen extends StatefulWidget {
  final String email;
  const ChatScreen({super.key, required this.email});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController message = TextEditingController();
  var base64String;

  Future getImage() async {
    ImagePicker picker = ImagePicker();

    await picker.pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        XFile imageFile = XFile(value.path);
        Uint8List imagebytes = await imageFile.readAsBytes();
        base64String = base64.encode(imagebytes);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    fireStore.collection('Messages').doc().set({
      'message': "",
      'image': base64String,
      'time': DateTime.now(),
      'email': widget.email,
    });
  }

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
            ),
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
                email: widget.email,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 300,
                              ),
                              child: SafeArea(
                                child: TextFormField(
                                  maxLines: null,
                                  controller: message,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    hintText: 'message',
                                    enabled: true,
                                    contentPadding:
                                        EdgeInsets.only(left: 14.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  onSaved: (value) {
                                    message.text = value!;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => getImage(),
                          icon: const Icon(Icons.image),
                        ),
                        IconButton(
                          onPressed: () {
                            if (message.text.isNotEmpty) {
                              String plainText, encryptionText;
                              plainText = message.text.trim();
                              encryptionText = Encryption.encrypt(plainText);
                              fireStore.collection('Messages').doc().set({
                                'message': encryptionText,
                                'image': "",
                                'time': DateTime.now(),
                                'email': widget.email,
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
            ),
          ],
        ),
      ),
    );
  }
}
