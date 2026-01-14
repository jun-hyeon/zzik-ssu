package com.example.zzik_ssu

import android.content.Context
import android.net.Uri
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class ImagePickerHelper(private val context: Context) {

    fun handleResult(uri: Uri?, result: MethodChannel.Result?){
        if(uri != null){
            val filePath = copyUriToCache(uri)
            if(filePath != null){
                result?.success(filePath)
            }else{
                result?.error("COPY_FAILED", "Failed to copy image to cache", null)
            }
        }else{
            result?.success(null)
        }
    }

    private fun copyUriToCache(uri: Uri): String?{
        return try {
            val contentResolver = context.contentResolver
            val inputStream = contentResolver.openInputStream(uri)

            val fileName = "picked_image_${System.currentTimeMillis()}.jpg"
            val tempFile = File(context.cacheDir, fileName)

            val outputStream = FileOutputStream(tempFile)

            inputStream?.use { input ->
                outputStream.use { output ->
                    input.copyTo(output)
                }
            }
            tempFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}
