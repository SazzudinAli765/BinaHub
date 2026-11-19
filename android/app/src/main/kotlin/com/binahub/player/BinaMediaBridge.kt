package com.binahub.player

import android.Manifest
import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebResourceResponse
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject
import java.io.InputStream
import java.util.Locale

/**
 * BinaMediaBridge: Bridges Android native MediaStore & Storage Access Framework (SAF)
 * to the Cyberpunk HTML5 Web Player.
 */
class BinaMediaBridge(private val activity: Activity) {

    companion object {
        private const val TAG = "BinaMediaBridge"
        const val PERMISSION_REQUEST_CODE = 4040
    }

    fun hasStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val videoPerm = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_MEDIA_VIDEO)
            val audioPerm = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_MEDIA_AUDIO)
            videoPerm == PackageManager.PERMISSION_GRANTED && audioPerm == PackageManager.PERMISSION_GRANTED
        } else {
            val storagePerm = ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE)
            storagePerm == PackageManager.PERMISSION_GRANTED
        }
    }

    @JavascriptInterface
    fun checkPermissions(): Boolean {
        return hasStoragePermission()
    }

    @JavascriptInterface
    fun requestPermissions() {
        activity.runOnUiThread {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(
                        Manifest.permission.READ_MEDIA_VIDEO,
                        Manifest.permission.READ_MEDIA_AUDIO
                    ),
                    PERMISSION_REQUEST_CODE
                )
            } else {
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                    PERMISSION_REQUEST_CODE
                )
            }
        }
    }

    @JavascriptInterface
    fun getDeviceVideos(): String {
        val result = JSONArray()
        if (!hasStoragePermission()) {
            Log.w(TAG, "getDeviceVideos requested without storage permission")
            return result.toString()
        }

        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.TITLE,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.WIDTH,
            MediaStore.Video.Media.HEIGHT,
            MediaStore.Video.Media.DATE_ADDED
        )

        val sortOrder = "${MediaStore.Video.Media.DATE_ADDED} DESC"

        try {
            val cursor: Cursor? = activity.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                sortOrder
            )

            cursor?.use {
                val idCol = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                val titleCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.TITLE)
                val nameCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
                val durationCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
                val sizeCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
                val widthCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.WIDTH)
                val heightCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.HEIGHT)

                while (it.moveToNext()) {
                    val id = it.getLong(idCol)
                    val title = it.getString(titleCol) ?: "Untitled Video"
                    val name = it.getString(nameCol) ?: title
                    val durationMs = it.getLong(durationCol)
                    val sizeBytes = it.getLong(sizeCol)
                    val width = it.getInt(widthCol)
                    val height = it.getInt(heightCol)

                    val contentUri = ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                    
                    // Virtual stream URL routed through WebViewAssetLoader interceptor
                    val streamUrl = "https://appassets.androidplatform.net/local-media/video/$id"

                    val item = JSONObject().apply {
                        put("id", id)
                        put("title", title)
                        put("fileName", name)
                        put("src", streamUrl)
                        put("contentUri", contentUri.toString())
                        put("durationSec", durationMs / 1000)
                        put("durationFormatted", formatDuration(durationMs))
                        put("sizeFormatted", formatFileSize(sizeBytes))
                        put("resolution", if (width > 0 && height > 0) "${width}x${height}" else "HD")
                        put("tag", if (height >= 1080) "FHD" else if (height >= 720) "HD" else "SD")
                        put("isLocalDevice", true)
                    }
                    result.put(item)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error querying device videos", e)
        }

        Log.i(TAG, "Scanned ${result.length()} device videos")
        return result.toString()
    }

    @JavascriptInterface
    fun getDeviceAudios(): String {
        val result = JSONArray()
        if (!hasStoragePermission()) {
            Log.w(TAG, "getDeviceAudios requested without storage permission")
            return result.toString()
        }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.SIZE
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        try {
            val cursor: Cursor? = activity.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                null,
                sortOrder
            )

            cursor?.use {
                val idCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
                val titleCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
                val nameCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
                val artistCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
                val albumCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
                val durationCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
                val sizeCol = it.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)

                while (it.moveToNext()) {
                    val id = it.getLong(idCol)
                    val title = it.getString(titleCol) ?: "Untitled Track"
                    val name = it.getString(nameCol) ?: title
                    val artist = it.getString(artistCol) ?: "Unknown Artist"
                    val album = it.getString(albumCol) ?: "Local Music"
                    val durationMs = it.getLong(durationCol)
                    val sizeBytes = it.getLong(sizeCol)

                    val streamUrl = "https://appassets.androidplatform.net/local-media/audio/$id"

                    val item = JSONObject().apply {
                        put("id", id)
                        put("title", title)
                        put("fileName", name)
                        put("artist", artist)
                        put("album", album)
                        put("src", streamUrl)
                        put("durationSec", durationMs / 1000)
                        put("durationFormatted", formatDuration(durationMs))
                        put("sizeFormatted", formatFileSize(sizeBytes))
                        put("isLocalDevice", true)
                    }
                    result.put(item)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error querying device audios", e)
        }

        Log.i(TAG, "Scanned ${result.length()} device audio tracks")
        return result.toString()
    }

    /**
     * Intercepts and streams content:// media when requested via the virtual domain
     */
    fun openMediaStream(uriString: String): WebResourceResponse? {
        return try {
            val uri = Uri.parse(uriString)
            val path = uri.path ?: return null
            
            val contentUri: Uri = when {
                path.startsWith("/local-media/video/") -> {
                    val id = path.substringAfter("/local-media/video/").toLongOrNull() ?: return null
                    ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id)
                }
                path.startsWith("/local-media/audio/") -> {
                    val id = path.substringAfter("/local-media/audio/").toLongOrNull() ?: return null
                    ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)
                }
                else -> return null
            }

            val inputStream: InputStream? = activity.contentResolver.openInputStream(contentUri)
            val mimeType = activity.contentResolver.getType(contentUri) ?: if (path.contains("video")) "video/mp4" else "audio/mpeg"

            if (inputStream != null) {
                WebResourceResponse(mimeType, "UTF-8", inputStream)
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stream media: $uriString", e)
            null
        }
    }

    private fun formatDuration(durationMs: Long): String {
        val totalSec = durationMs / 1000
        val min = totalSec / 60
        val sec = totalSec % 60
        return String.format(Locale.US, "%02d:%02d", min, sec)
    }

    private fun formatFileSize(bytes: Long): String {
        if (bytes <= 0) return "0 B"
        val mb = bytes.toDouble() / (1024 * 1024)
        return if (mb >= 1000) {
            String.format(Locale.US, "%.1f GB", mb / 1024)
        } else {
            String.format(Locale.US, "%.1f MB", mb)
        }
    }
}
