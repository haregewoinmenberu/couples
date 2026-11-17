package com.oursound.oursound

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "oursound/device_phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call: MethodCall, result ->
                if (call.method == "getPhoneNumber") {
                    result.success(readPhoneNumber())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun readPhoneNumber(): String? {
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_PHONE_STATE
            ) != PackageManager.PERMISSION_GRANTED
        ) return null

        return try {
            val telephony = getSystemService(TELEPHONY_SERVICE) as? TelephonyManager
            @Suppress("MissingPermission")
            val number = telephony?.line1Number
            if (number.isNullOrBlank() || number == "Unknown") null else number
        } catch (_: Exception) {
            null
        }
    }
}
