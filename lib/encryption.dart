import 'package:encrypt/encrypt.dart';
import 'package:rot13/rot13.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Encryption {
  //AES setup
  static final key = Key.fromLength(32);
  static final iv = IV.fromLength(16);

  // Password hashing with SHA
  static String passwordHashSHA(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  //Super Enkripsi dengan ROT13 dan AES
  static String encrypt(String plainText) {
    final encryptROT13 = rot13(plainText).toString();
    final encrypterAES = Encrypter(AES(key));
    final encryptedAES = encrypterAES.encrypt(encryptROT13, iv: iv);
    return encryptedAES.base64;
  }

  static String decrypt(String encryptedText) {
    final encrypterAES = Encrypter(AES(key));
    final decryptedAES = encrypterAES.decrypt64(encryptedText, iv: iv);
    final decryptROT13 = rot13(decryptedAES);
    return decryptROT13.toString();
  }

  static String encryptGambar(String plainImage) {
    final encrypterAES = Encrypter(AES(key));
    final encryptedAES = encrypterAES.encrypt(plainImage, iv: iv);
    return encryptedAES.base64;
  }

  static String decryptGambar(String cipherImage) {
    final encrypterAES = Encrypter(AES(key));
    final decryptedAES = encrypterAES.decrypt64(cipherImage, iv: iv);
    return decryptedAES;
  }
}
