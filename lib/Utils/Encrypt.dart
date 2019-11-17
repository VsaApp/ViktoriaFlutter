import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

import 'package:viktoriaflutter/Utils/Keys.dart';
import 'package:viktoriaflutter/Utils/Storage.dart';

String encryptText(String text) {
  String userPassword = Storage.getString(Keys.password);
  final hash = sha256.convert(utf8.encode(userPassword));
  final key = encrypt.Key.fromBase16(hash.toString());
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  return encrypter.encrypt(text, iv: iv).base16;
}

String decryptText(String text) {
  String userPassword = Storage.getString(Keys.password);
  final hash = sha256.convert(utf8.encode(userPassword));
  final key = encrypt.Key.fromBase16(hash.toString());
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypt.Encrypted.fromBase16(text);
  return encrypter.decrypt(encrypted, iv: iv);
}
