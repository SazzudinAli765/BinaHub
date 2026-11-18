package com.binahub.player

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Color
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
    }

    private lateinit var webView: WebView
    private var hasLoadedSuccessfully = false

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        // Safe global exception guard to prevent direct home screen crashes
        setupCrashGuard()

        super.onCreate(savedInstanceState)

        try {
            // 1. Safe window and edge-to-edge system bar styling
            setupSystemWindowBars()

            // 2. Initialize Hardware-Accelerated WebView
            webView = WebView(applicationContext).apply {
                setBackgroundColor(Color.parseColor("#05080C"))
                setLayerType(View.LAYER_TYPE_HARDWARE, null)

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

                // 3. Register Security & Protection Interface for SazzudinAli
                val securityGuard = BinaSecurityGuard(this@MainActivity)
                addJavascriptInterface(securityGuard, "BinaSecurity")

                // 4. Dual Asset Loader with Fallback
                val assetLoader = WebViewAssetLoader.Builder()
                    .addPathHandler("/assets/", WebViewAssetLoader.AssetsPathHandler(this@MainActivity))
                    .build()

                webViewClient = object : WebViewClient() {
                    override fun shouldInterceptRequest(
                        view: WebView?,
                        request: WebResourceRequest?
                    ): WebResourceResponse? {
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
                        
                        // Inject Security HUD Banner into DOM if ready
                        view?.evaluateJavascript("""
                            (function() {
                                if (window.BinaSecurity && !document.getElementById('binahub-sec-pill')) {
                                    try {
                                        var pill = document.createElement('div');
                                        pill.id = 'binahub-sec-pill';
                                        pill.style.position = 'fixed';
                                        pill.style.bottom = '8px';
                                        pill.style.right = '8px';
                                        pill.style.zIndex = '999999';
                                        pill.style.background = 'rgba(7, 10, 14, 0.88)';
                                        pill.style.border = '1px solid #00F0FF';
                                        pill.style.color = '#00F0FF';
                                        pill.style.fontSize = '9px';
                                        pill.style.fontWeight = '700';
                                        pill.style.fontFamily = 'monospace';
                                        pill.style.padding = '3px 7px';
                                        pill.style.borderRadius = '3px';
                                        pill.style.letterSpacing = '0.5px';
                                        pill.style.pointerEvents = 'none';
                                        pill.style.boxShadow = '0 0 10px rgba(0, 240, 255, 0.3)';
                                        pill.innerText = '🛡️ ' + window.BinaSecurity.getOwner().toUpperCase() + ' • ' + (window.BinaSecurity.isProtected() ? 'PROTECTED' : 'DEV');
                                        document.body.appendChild(pill);
                                    } catch(e) {}
                                }
                            })();
                        """.trimIndent(), null)
                    }

                    override fun onReceivedError(
                        view: WebView?,
                        errorCode: Int,
                        description: String?,
                        failingUrl: String?
                    ) {
                        Log.w(TAG, "WebView error ($errorCode): $description for $failingUrl")
                        // If domain loader fails, fallback to file:///android_asset/index.html
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

                    override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                        Log.d("BinaHubConsole", "[JS ${consoleMessage?.messageLevel()}] ${consoleMessage?.message()} (${consoleMessage?.sourceId()}:${consoleMessage?.lineNumber()})")
                        return true
                    }
                }
            }

            setContentView(webView)
            // Primary URL load
            webView.loadUrl(ASSET_DOMAIN_URL)

        } catch (t: Throwable) {
            Log.e(TAG, "Fatal startup exception caught in onCreate", t)
            displayCrashFallbackUI(t)
        }
    }

    private fun setupSystemWindowBars() {
        try {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            window.statusBarColor = Color.parseColor("#05080C")
            window.navigationBarColor = Color.parseColor("#070A0E")

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
                   "Owner: SazzudinAli (Protection Active)\n" +
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
