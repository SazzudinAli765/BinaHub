package com.binahub.player

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.webkit.*
import android.widget.FrameLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.webkit.WebViewAssetLoader

class MainActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "BinaHubMain"
        private const val ASSET_DOMAIN_URL = "https://appassets.androidplatform.net/assets/index.html"
        private const val LOCAL_FILE_URL = "file:///android_asset/index.html"
        private const val FILE_CHOOSER_REQUEST_CODE = 5050
    }

    private lateinit var webView: WebView
    private lateinit var mediaBridge: BinaMediaBridge
    private var fileChooserCallback: ValueCallback<Array<Uri>>? = null
    private var hasLoadedSuccessfully = false

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        setupCrashGuard()
        super.onCreate(savedInstanceState)

        try {
            // 1. Fullscreen Window & Edge-to-Edge setup (No fake status bar)
            setupSystemWindowBars()

            // 2. Initialize Media & Storage Bridge
            mediaBridge = BinaMediaBridge(this)

            // 3. Initialize Hardware-Accelerated Fullscreen WebView
            webView = WebView(this).apply {
                setBackgroundColor(Color.parseColor("#05080C"))
                setLayerType(View.LAYER_TYPE_HARDWARE, null)
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                settings.apply {
                    javaScriptEnabled = true
                    domStorageEnabled = true
                    databaseEnabled = true
                    mediaPlaybackRequiresUserGesture = false
                    allowFileAccess = true
                    allowContentAccess = true
                    allowFileAccessFromFileURLs = true
                    allowUniversalAccessFromFileURLs = true
                    setSupportZoom(false)
                    useWideViewPort = true
                    loadWithOverviewMode = true
                    cacheMode = WebSettings.LOAD_DEFAULT
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
                    }
                }

                // Register Native Bridges for Web App
                val securityGuard = BinaSecurityGuard(this@MainActivity)
                addJavascriptInterface(securityGuard, "BinaSecurity")
                addJavascriptInterface(mediaBridge, "BinaMediaBridge")

                val assetLoader = WebViewAssetLoader.Builder()
                    .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this@MainActivity))
                    .build()

                webViewClient = object : WebViewClient() {
                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
                        val urlStr = request?.url?.toString() ?: ""
                        // Handle streaming of real device videos and songs
                        if (urlStr.contains("/local-media/")) {
                            val stream = mediaBridge.openMediaStream(urlStr)
                            if (stream != null) return stream
                        }

                        return try {
                            request?.url?.let { assetLoader.shouldInterceptRequest(it) }
                        } catch (e: Exception) {
                            Log.e(TAG, "Asset loader intercept error", e)
                            null
                        }
                    }

                    override fun onPageFinished(view: WebView?, url: String?) {
                        super.onPageFinished(view, url)
                        hasLoadedSuccessfully = true
                        Log.i(TAG, "Page loaded successfully: $url")
                        
                        // Automatically check & trigger device storage scan if permissions are ready
                        if (mediaBridge.hasStoragePermission()) {
                            view?.evaluateJavascript("if (window.onStoragePermissionsGranted) { window.onStoragePermissionsGranted(); }", null)
                        }
                    }

                    override fun onReceivedError(
                        view: WebView?,
                        errorCode: Int,
                        description: String?,
                        failingUrl: String?
                    ) {
                        Log.w(TAG, "WebView error ($errorCode): $description for $failingUrl")
                        if (!hasLoadedSuccessfully && failingUrl == ASSET_DOMAIN_URL) {
                            Log.i(TAG, "Triggering fallback to $LOCAL_FILE_URL")
                            view?.loadUrl(LOCAL_FILE_URL)
                        }
                    }
                }

                webChromeClient = object : WebChromeClient() {
                    override fun onPermissionRequest(request: PermissionRequest?) {
                        try {
                            request?.grant(request.resources)
                        } catch (e: Exception) {
                            Log.e(TAG, "Permission request grant failed", e)
                        }
                    }

                    // Native Android File Picker support for <input type="file">
                    override fun onShowFileChooser(
                        mWebView: WebView?,
                        filePathCallback: ValueCallback<Array<Uri>>?,
                        fileChooserParams: FileChooserParams?
                    ): Boolean {
                        fileChooserCallback?.onReceiveValue(null)
                        fileChooserCallback = filePathCallback

                        val intent = fileChooserParams?.createIntent() ?: Intent(Intent.ACTION_GET_CONTENT).apply {
                            type = "*/*"
                            addCategory(Intent.CATEGORY_OPENABLE)
                        }

                        return try {
                            startActivityForResult(intent, FILE_CHOOSER_REQUEST_CODE)
                            true
                        } catch (e: Exception) {
                            Log.e(TAG, "Cannot launch file chooser intent", e)
                            fileChooserCallback = null
                            false
                        }
                    }

                    override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                        Log.d("BinaHubConsole", "[JS ${consoleMessage?.messageLevel()}] ${consoleMessage?.message()} (${consoleMessage?.sourceId()}:${consoleMessage?.lineNumber()})")
                        return true
                    }
                }
            }

            setContentView(webView)
            webView.loadUrl(ASSET_DOMAIN_URL)

            // Auto-request storage permission on first launch so user sees the prompt immediately
            if (!mediaBridge.hasStoragePermission()) {
                mediaBridge.requestPermissions()
            }

        } catch (t: Throwable) {
            Log.e(TAG, "Fatal startup exception caught in onCreate", t)
            displayCrashFallbackUI(t)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == FILE_CHOOSER_REQUEST_CODE) {
            val result = WebChromeClient.FileChooserParams.parseResult(resultCode, data)
            fileChooserCallback?.onReceiveValue(result)
            fileChooserCallback = null
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == BinaMediaBridge.PERMISSION_REQUEST_CODE) {
            val isGranted = grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            Log.i(TAG, "Storage permission result: $isGranted")
            if (this::webView.isInitialized) {
                if (isGranted) {
                    webView.evaluateJavascript("if (window.onStoragePermissionsGranted) { window.onStoragePermissionsGranted(); }", null)
                } else {
                    webView.evaluateJavascript("if (window.onStoragePermissionsDenied) { window.onStoragePermissionsDenied(); }", null)
                }
            }
        }
    }

    private fun setupSystemWindowBars() {
        try {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.statusBarColor = Color.parseColor("#05080C")
            window.navigationBarColor = Color.parseColor("#05080C")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.insetsController?.setSystemBarsAppearance(
                    0,
                    WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS
                )
            }
        } catch (e: Exception) {
            Log.w(TAG, "System bar customization warning", e)
        }
    }

    private fun setupCrashGuard() {
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            Log.e(TAG, "Uncaught exception on thread ${thread.name}", throwable)
            try {
                runOnUiThread {
                    displayCrashFallbackUI(throwable)
                }
            } catch (ignored: Exception) {
                defaultHandler?.uncaughtException(thread, throwable)
            }
        }
    }

    private fun displayCrashFallbackUI(t: Throwable) {
        val container = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#05080C"))
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setPadding(40, 80, 40, 40)
        }

        val tv = TextView(this).apply {
            setTextColor(Color.parseColor("#00F0FF"))
            textSize = 14f
            text = "=== BINAHUB RECOVERY HUD ===\n\n" +
                   "Status: Fallback Activated\n\n" +
                   "Diagnostic Trace:\n${t.localizedMessage}\n\n" +
                   t.stackTrace.take(6).joinToString("\n") { "  at $it" } +
                   "\n\nTap anywhere to reload..."
            setOnClickListener {
                recreate()
            }
        }

        container.addView(tv)
        setContentView(container)
    }

    override fun onBackPressed() {
        if (this::webView.isInitialized && webView.canGoBack()) {
            webView.goBack()
        } else {
            super.onBackPressed()
        }
    }
}
