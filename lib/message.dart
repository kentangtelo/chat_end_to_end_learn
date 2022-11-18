import 'dart:convert';
import 'dart:typed_data';
import 'package:chat_end_to_end/encryption.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageStream extends StatefulWidget {
  String email;
  MessageStream({super.key, required this.email});

  @override
  State<MessageStream> createState() => _MessageStreamState();
}

class _MessageStreamState extends State<MessageStream> {
  Uint8List? decoded64String;

  final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
      .collection('Messages')
      .orderBy('time')
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _messageStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("something is wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          primary: true,
          itemBuilder: (_, index) {
            QueryDocumentSnapshot qs = snapshot.data!.docs[index];
            var imageEncrypted = qs['image'];
            var cipherText = qs['message'];
            var decryptionImage = "";
            String decryptionText = "";
            if (cipherText != "") {
              decryptionText = Encryption.decrypt(cipherText);
            }
            if (imageEncrypted != "") {
              decryptionImage = Encryption.decryptGambar(imageEncrypted);
              decoded64String = base64.decode(decryptionImage);
            }
            Timestamp t = qs['time'];
            DateTime d = t.toDate();
            return Padding(
              padding: const EdgeInsets.only(
                left: 8,
                top: 8,
                bottom: 8,
                right: 8,
              ),
              child: Column(
                crossAxisAlignment: widget.email == qs['email']
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(
                        qs['email'],
                        style: const TextStyle(
                          color: Color.fromARGB(255, 47, 17, 241),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: cipherText != ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    decryptionText,
                                    // softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Text(
                                  "${d.hour}:${d.minute}",
                                )
                              ],
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height / 2.5,
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 5,
                              ),
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height / 2.5,
                                width: MediaQuery.of(context).size.height / 2,
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                ),
                                child: Image.memory(
                                  Uint8List.fromList(decoded64String!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
