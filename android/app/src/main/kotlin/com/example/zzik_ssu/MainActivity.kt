package com.example.zzik_ssu

import androidx.core.content.FileProvider

import android.net.Uri
import android.util.Log
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream
import java.util.UUID

class MainActivity : FlutterFragmentActivity(){
    private var CHANNEL = "com.example.zzik_ssu/pickImage"
    private var pendingResult: MethodChannel.Result? = null
    private val imagePickerHelper by lazy { ImagePickerHelper(this) }

    private val pickMedia = registerForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
        // Callback is invoked after the user selects a media item or closes the
        // photo picker.
        imagePickerHelper.handleResult(uri, pendingResult)
        pendingResult = null
    }

    private var cameraUri: Uri? = null
    private val takePicture = registerForActivityResult(ActivityResultContracts.TakePicture()) { success ->
        if (success && cameraUri != null) {
            imagePickerHelper.handleResult(cameraUri, pendingResult)
        } else {
            pendingResult?.success(null)
        }
        pendingResult = null
    }



    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if(call.method == "pickImage"){
                pendingResult = result

                if(ActivityResultContracts.PickVisualMedia.isPhotoPickerAvailable(this)){
                    pickMedia.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                }else{
                    result.error("UNSUPPORTED", "Photo Picker not available on this device", null)
                }

            }else if (call.method == "pickImageFromCamera") {
                pendingResult = result
                val tempFile = File(cacheDir, "camera_capture_${System.currentTimeMillis()}.jpg")
                try {
                    tempFile.createNewFile()
                    cameraUri = FileProvider.getUriForFile(this, "${applicationContext.packageName}.fileprovider", tempFile)
                    takePicture.launch(cameraUri)
                } catch (e: Exception) {
                    result.error("CAMERA_INIT_FAILED", "Failed to create temp file", e.message)
                    pendingResult = null
                }
            }else{
                result.notImplemented()
            }
        }
    }


}
