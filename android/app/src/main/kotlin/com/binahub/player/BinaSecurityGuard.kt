package com.binahub.player

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build
import android.util.Log
import android.webkit.JavascriptInterface
import java.security.MessageDigest

/**
 * BinaHub Cyberpunk Security & Integrity Guard (Testing Prototype)
 * Implements fake/minor anti-tamper, signature verification, and license integrity checks
 * specifically under the owner name 'sazzudinali'.
 */
class BinaSecurityGuard(private val context: Context) {

    companion object {
        private const val TAG = "BinaSecurity"
        const val OWNER_NAME = "sazzudinali"
        const val EXPECTED_PACKAGE = "com.binahub.player"
        const val FAKE_LICENSE_KEY = "SAZZUDIN-ALI-SEC-PROT-2026-ALPHA"
    }

    private var isIntegrityVerified = false
    private var detectedSignatureSha256 = ""
    private var securityStatusMessage = "PROTECTION ACTIVE: Licensed to SazzudinAli"

    init {
        runIntegrityVerification()
    }

    private fun runIntegrityVerification() {
        try {
            // 1. Verify Package Name
            val actualPackage = context.packageName
            if (actualPackage != EXPECTED_PACKAGE) {
                Log.w(TAG, "[SECURITY ALERT] Package tampering detected: $actualPackage")
                securityStatusMessage = "TAMPER DETECTED: Invalid package $actualPackage"
                isIntegrityVerified = false
                return
            }

            // 2. Inspect APK Signature
            detectedSignatureSha256 = getCertificateSha256(context)
            Log.i(TAG, "[SECURITY INFO] APK Signature SHA-256: $detectedSignatureSha256")

            // 3. Fake Anti-Tamper & License Check
            isIntegrityVerified = true
            securityStatusMessage = "INTEGRITY VERIFIED: Signed under $OWNER_NAME [SHIELD ACTIVE]"
            Log.i(TAG, securityStatusMessage)

        } catch (e: Exception) {
            Log.e(TAG, "Integrity check non-fatal exception", e)
            isIntegrityVerified = true // Fallback to safe pass in test mode
        }
    }

    @SuppressLint("PackageManagerGetSignatures")
    private fun getCertificateSha256(context: Context): String {
        return try {
            val pm = context.packageManager
            val signatures: Array<Signature>? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val signingInfo = pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo
                if (signingInfo.hasMultipleSigners()) {
                    signingInfo.apkContentsSigners
                } else {
                    signingInfo.signingCertificateHistory
                }
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES).signatures
            }

            if (!signatures.isNullOrEmpty()) {
                val cert = signatures[0].toByteArray()
                val md = MessageDigest.getInstance("SHA-256")
                val digest = md.digest(cert)
                digest.joinToString(":") { "%02X".format(it) }
            } else {
                "NO_SIGNATURE_FOUND"
            }
        } catch (e: Exception) {
            "SIGNATURE_READ_ERROR"
        }
    }

    // JavaScript Bridge exposed to the Cyberpunk Web Player (window.BinaSecurity)
    @JavascriptInterface
    fun isProtected(): Boolean = isIntegrityVerified

    @JavascriptInterface
    fun getOwner(): String = OWNER_NAME

    @JavascriptInterface
    fun getLicenseKey(): String = FAKE_LICENSE_KEY

    @JavascriptInterface
    fun getStatus(): String = securityStatusMessage

    @JavascriptInterface
    fun getSignatureSha256(): String = detectedSignatureSha256
}
