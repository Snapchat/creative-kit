package com.snap.creativekit.lite.demo

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.text.TextUtils
import android.util.Base64
import android.util.Log
import org.json.JSONException
import org.json.JSONObject

object CKLite {
    private const val RESULT_INTENT_EXTRA = "RESULT_INTENT"
    private const val CREATIVE_KIT_LITE_REQUEST_CODE =
        100 // 3P app can decide your own request code
    private const val SNAPCHAT_PACKAGE = "com.snapchat.android"
    private const val INTENT_URI_CAMERA = "snapchat://creativekit/camera"
    private const val INTENT_URI_PREVIEW = "snapchat://creativekit/preview"
    public const val INTENT_TYPE_ALL = "*/*"
    public const val INTENT_TYPE_IMAGE = "image/*"
    public const val INTENT_TYPE_VIDEO = "video/*"
    private const val KEY_CLIENT_ID = "CLIENT_ID"
    private const val KEY_LENS_ID = "lensUUID"
    private const val CAPTION_TEXT_EXTRA = "captionText"
    private const val APP_NAME_EXTRA = "CLIENT_APP_NAME"
    private const val STICKER_EXTRA = "sticker"

    fun shareToDynamicLens(
        context: Context,
        lensUUID: String?,
        clientID: String,
        launchData: JSONObject
    ): Intent {
        val intent = getBaseIntent(context, clientID, INTENT_URI_CAMERA, INTENT_TYPE_ALL)
        intent.putExtra(KEY_LENS_ID, lensUUID) // From Manage Lenses Portal
        var lensLaunchData: String? = null
        try {
            val jsonString = launchData.toString().toByteArray(charset("UTF-8"))
            lensLaunchData = Base64.encodeToString(jsonString, Base64.NO_WRAP)
        } catch (e: Exception) {
            Log.w("cklite-json", "Hit json exception for lens data", e)
        }
        if (lensLaunchData != null) {
            intent.putExtra("lensLaunchData", lensLaunchData)
        }
        return intent
    }

    fun addSticker(
        intent: Intent,
        stickerUri: Uri,
        posX: Float = 0.5f,
        posY: Float = 0.5f,
        rotation: Float = 0f,
        widthDp: Int = 200,
        heightDp: Int = 200,
    ) {
        try {
            val stickerJson = JSONObject()
            stickerJson.put("uri", stickerUri)
            stickerJson.put("posX", posX) // range of 0-1 as a Double (eg: 0.5)
            stickerJson.put("posY", posY) // range of 0-1 as a Double (eg: 0.5)
            stickerJson.put("rotation", rotation) //  in degrees, range 0 - 360.
            stickerJson.put("widthDp", widthDp) // in dp (density indpentdent pixels)
            stickerJson.put("heightDp", heightDp) // in dp (density indpentdent pixels)
            intent.putExtra(STICKER_EXTRA, stickerJson.toString())
        } catch (ex: JSONException) {
            Log.w("ck-lite", "Couldn't create sticker Json")
        }
    }

    fun shareToCamera(
        context: Context,
        clientID: String,
        caption: String?,
        appName: String?
    ): Intent {
        val intent = getBaseIntent(context, clientID, INTENT_URI_CAMERA, INTENT_TYPE_ALL)
        intent.putExtra(APP_NAME_EXTRA, appName)
        if (!TextUtils.isEmpty(caption)) {
            intent.putExtra(CAPTION_TEXT_EXTRA, caption)
        }

        return intent
    }

    fun shareToPreview(
        context: Context,
        clientID: String,
        intentType: String,
        fileUri: Uri,
        caption: String?
    ): Intent {
        val intent = getBaseIntent(context, clientID, INTENT_URI_PREVIEW, intentType)
        if (!TextUtils.isEmpty(caption)) {
            intent.putExtra(CAPTION_TEXT_EXTRA, caption)
        }
        intent.putExtra(
            Intent.EXTRA_STREAM, fileUri
        )
        return intent
    }

    private fun getBaseIntent(
        context: Context,
        clientID: String,
        intentUri: String,
        intentType: String
    ): Intent {
        val intent = Intent(Intent.ACTION_SEND)
        intent.setPackage(SNAPCHAT_PACKAGE)
        intent.putExtra(KEY_CLIENT_ID, clientID)
        intent.setDataAndType(Uri.parse(intentUri), intentType)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        intent.putExtra(
            RESULT_INTENT_EXTRA, PendingIntent.getActivity(
                context,
                CREATIVE_KIT_LITE_REQUEST_CODE,
                Intent(),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_IMMUTABLE else PendingIntent.FLAG_ONE_SHOT
            )
        )
        return intent
    }
}