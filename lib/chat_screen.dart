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
  var encryptBase64String;

  Future getImage() async {
    ImagePicker picker = ImagePicker();

    await picker.pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        XFile imageFile = XFile(value.path);
        Uint8List imagebytes = await imageFile.readAsBytes();
        var base64String = base64.encode(imagebytes);
        encryptBase64String = Encryption.encryptGambar(base64String);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    fireStore.collection('Messages').doc().set({
      'message': "",
      'image': encryptBase64String,
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: MessageStream(
                    email: widget.email,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => getImage(),
                      icon: const Icon(
                        Icons.image,
                      )),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Card(
                      margin: const EdgeInsets.only(
                        left: 2,
                        right: 2,
                        bottom: 8,
                      ),
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: message,
                        decoration: const InputDecoration(
                          filled: true,
                          hintText: 'message',
                          enabled: true,
                          contentPadding: EdgeInsets.only(
                              top: 2.0, left: 13.0, right: 13.0, bottom: 10.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
