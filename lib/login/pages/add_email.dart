import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

List semail = [];
void AddEmail(String email, String name, String role, File? image) async {
  final CollectionReference userverif =
      FirebaseFirestore.instance.collection('userverif');
  bool exist = false;
  final records =
      await FirebaseFirestore.instance.collection('userverif').get();
  semail = records.docs.map((e) => e.data()).toList();
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference storageReference =
      FirebaseStorage.instance.ref().child('images/$fileName.jpg');
  UploadTask uploadTask = storageReference.putFile(image!);

  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
  String imageUrl = await taskSnapshot.ref.getDownloadURL();

  if (semail.isEmpty) {
    await userverif.doc(email).set(
        {"email": email, "role": role, "name": name, "imageUrl": imageUrl});
  } else {
    for (var i = 0; i < semail.length; i++) {
      if (semail[i]['email'].toString() == email.toString()) {
        exist = true;
      }
    }
    if (!exist) {
      await userverif.doc(email).set(
          {"email": email, "role": role, "name": name, "imageUrl": imageUrl});
    }
  }
  return;
}
