import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/service/native_image_picker.dart';

part 'scan_repository.g.dart';

@riverpod
ScanRepository scanRepository(Ref ref) {
  return ScanRepository();
}

class ScanRepository {
  final ImagePicker _picker = ImagePicker();
  final NativeImagePicker _nativeImagePicker = NativeImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos; // or Permission.storage for Android < 13

    if (await permission.request().isGranted) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        return await _cropImage(pickedFile);
      }
    } else {
      // Handle permission denied
      if (await permission.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    return null;
  }

  Future<File?> pickImageNative() async {
    final pickedFile = await _nativeImagePicker.pickImage();
    if (pickedFile != null) {
      log("이미지가 선택되엇습니다.$pickedFile");
      return File(pickedFile);
    }
    return null;
  }

  Future<File?> pickImageNativeFromCamera() async {
    final pickedFile = await _nativeImagePicker.pickImageFromCamera();
    if (pickedFile != null) {
      log("카메라로 촬용되었습니다.$pickedFile");
      return File(pickedFile);
    }
    return null;
  }

  Future<XFile?> _cropImage(XFile imageFile) async {
    // Note: ensure you have setup generic usage in AndroidManifest.xml for crop
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '영수증 자르기',
          toolbarColor: const Color(0xFF6750A4), // M3 Purple (approx)
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: '영수증 자르기',
          doneButtonTitle: '완료',
          cancelButtonTitle: '취소',
        ),
      ],
    );

    return croppedFile != null ? XFile(croppedFile.path) : null;
  }
}
