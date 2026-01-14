import 'dart:developer';

import 'package:flutter/services.dart';

class NativeImagePicker {
  static const platform = MethodChannel('com.example.zzik_ssu/pickImage');

  Future<String?> pickImage() async {
    try {
      final String? path = await platform.invokeMethod('pickImage');
      return path;
    } on PlatformException catch (e) {
      log("Failed to pick image: ${e.message}");
      return null;
    }
  }

  Future<String?> pickImageFromCamera() async {
    try {
      final String? path = await platform.invokeMethod('pickImageFromCamera');
      return path;
    } on PlatformException catch (e) {
      log("Failed to pick image from camera: ${e.message}");
      return null;
    }
  }
}

enum AppImageSource { camera, gallery }
