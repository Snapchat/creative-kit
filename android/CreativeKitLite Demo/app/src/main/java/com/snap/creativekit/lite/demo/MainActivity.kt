package com.snap.creativekit.lite.demo

import android.content.ContentResolver
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import org.json.JSONException
import org.json.JSONObject
import java.io.*

const val RESULT_INTENT_EXTRA = "RESULT_INTENT"
const val CREATIVE_KIT_LITE_REQUEST_CODE = 9834 // 3P app can decide your own request code
const val CLIENT_ID = "01a6f1e4-5b9c-46fa-a9ca-f7fc9f09f112"
const val LENS_ID = "b400bacdc15d482db8da9d6655c58658"
const val SNAPCHAT_PACKAGE = "com.snapchat.android"

const val TAG = "CreativeKitLiteDemo"
class MainActivity : AppCompatActivity() {
    // region Android boilerplate
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        findViewById<Button>(R.id.preview_image_demo).setOnClickListener {
            launchSnapchatPreviewWithImage()
        }

        findViewById<Button>(R.id.preview_video_demo).setOnClickListener {
            launchSnapchatPreviewWithVideo()
        }

        findViewById<Button>(R.id.camera_demo).setOnClickListener {
            launchSnapchatCamera()
        }

        findViewById<Button>(R.id.camera_lens_demo).setOnClickListener {
            launchSnapchatCameraWithLens()
        }
    }

    // endregion

    // region Launch Snapchat

    private fun launchSnapchatPreviewWithImage() {
        val imageBitmap = BitmapFactory.decodeResource(this.resources, R.raw.normal_jpeg)
        val imageFile = saveBitmapToFile(imageBitmap, "normal_image")
        val fileUri = FileProvider.getUriForFile(
                applicationContext,
            "$packageName.fileprovider",
                imageFile!!
            )
        val intent = CKLite.shareToPreview(
            applicationContext,
            CLIENT_ID,
            CKLite.INTENT_TYPE_IMAGE,
            fileUri,
            "Image shared from $packageName");
        startActivity(intent);
    }

    private fun launchSnapchatPreviewWithVideo() {
        val path = "android.resource://" + packageName + "/" + R.raw.video_mp4
        val pathUri = Uri.parse(path)
        val videoFile = saveResourceUri(pathUri, "video.mp4")
        val fileUri = FileProvider.getUriForFile(
            applicationContext,
            "$packageName.fileprovider",
            videoFile!!
        )
        val intent = CKLite.shareToPreview(
            applicationContext,
            CLIENT_ID,
            CKLite.INTENT_TYPE_VIDEO,
            fileUri,
            "Video shared from $packageName");
        startActivity(intent);
    }

    private fun launchSnapchatCamera() {
        val intent = CKLite.shareToCamera(
            applicationContext,
            CLIENT_ID,
            "Shared to camera from $packageName",
            "My CK Lite demo"
        )
        val stickerBitmap = BitmapFactory.decodeResource(this.resources, R.raw.sticker_jpeg)
        val stickerFile = saveBitmapToFile(stickerBitmap, "jpegSticker.jpeg")

        stickerFile?.let {
            val stickerUri = FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                it
            )
            grantUriPermission(
                SNAPCHAT_PACKAGE,
                stickerUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
            CKLite.addSticker(intent, stickerUri)
        }

        startActivity(intent)
    }

    private fun launchSnapchatCameraWithLens() {
        val launchData = JSONObject()
        try {
            launchData.put("key1", "value of key 1")
            launchData.put("key2", "value of key 2")
        } catch (e: JSONException) {
            e.printStackTrace()
        }
        val intent = CKLite.shareToDynamicLens(
            applicationContext,
            LENS_ID,
            CLIENT_ID,
            launchData
        )
        startActivity(intent)
    }

    // endregion

    // region Internal Helpers
    private fun saveBitmapToFile(
        bitmap: Bitmap,
        filename: String,
        compressFormat: Bitmap.CompressFormat = Bitmap.CompressFormat.JPEG
    ): File? {
        val outFile = createNewFile(filename)
        try {
            if (!outFile.exists()) {
                outFile.createNewFile()
            }
        } catch (e: IOException) {
            return null
        }
        FileOutputStream(outFile).use {
                bitmapFile ->
            bitmap.compress(compressFormat, 70, bitmapFile)
        }
        return outFile
    }

    private fun createNewFile(filename: String): File {
        val imagesFolder = File(this.filesDir, "creative_kit_lite_demo")
        if (imagesFolder.exists() && !imagesFolder.isDirectory) {
            Log.w(TAG, "Removing file ${imagesFolder.absolutePath}")
            imagesFolder.delete()
        }

        if (!imagesFolder.exists()) {
            Log.i(TAG, "Creating folder ${imagesFolder.absolutePath}")
            imagesFolder.mkdir()
        }
        return File(imagesFolder, filename)
    }

    private fun saveResourceUri(resourceUri: Uri?, filename: String): File? {
        val resourceFile = createNewFile(filename)
        val resolver: ContentResolver = contentResolver

        val inputStream: InputStream?
        try {
            inputStream = resolver.openInputStream(resourceUri!!)
            saveInputStreamToFile(inputStream!!, resourceFile)
        } catch (e: FileNotFoundException) {
            showException(e)
            return null
        }
        return resourceFile
    }

    private fun saveInputStreamToFile(inputStream: InputStream, file: File) {
        var bos: BufferedOutputStream? = null

        var totalBytesRead = 0
        var readBytes: Int
        try {
            bos = BufferedOutputStream(FileOutputStream(file, false))
            val buf = ByteArray(1024)
            readBytes = inputStream.read(buf)
            while (readBytes != -1) {
                bos.write(buf)
                totalBytesRead += readBytes
                readBytes = inputStream.read(buf)
            }
        } catch (e: IOException) {
            showException(e)
        } finally {
            try {
                inputStream.close()
                bos?.close()
            } catch (e: IOException) {
                showException(e)
            }
        }
        Log.d(TAG, "Input stream bytes read = $totalBytesRead")
    }

    private fun showException(e: Exception) {
        Log.w(TAG, e)
        e.printStackTrace()
        Toast.makeText(this, e.message, Toast.LENGTH_LONG).show()
    }
}


