import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zzik_ssu/service/native_image_picker.dart';

part 'scan_repository.g.dart';

@riverpod
ScanRepository scanRepository(Ref ref) {
  return ScanRepository();
}

class ScanRepository {
  final NativeImagePicker _nativeImagePicker = NativeImagePicker();

  Future<File?> pickImageNative() async {
    final pickedFile = await _nativeImagePicker.pickImage();
    if (pickedFile != null) {
      log("이미지가 선택되었습니다. $pickedFile");
      return await _cropImage(File(pickedFile));
    }
    return null;
  }

  Future<File?> pickImageNativeFromCamera() async {
    final pickedFile = await _nativeImagePicker.pickImageFromCamera();
    if (pickedFile != null) {
      log("카메라로 촬영되었습니다. $pickedFile");
      return await _cropImage(File(pickedFile));
    }
    return null;
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 80,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '영수증 자르기',
          toolbarColor: const Color(0xFF6750A4),
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

    return croppedFile != null ? File(croppedFile.path) : null;
  }
}
