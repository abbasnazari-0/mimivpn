package com.arianadeveloper.ariana_vpn

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

private const val VPN_REQUEST_CODE = 1000
private const val TAG = "MainActivity"

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mimivpn.vpn"
    private val STATUS_CHANNEL = "com.mimivpn.vpn_events"
    private var eventSink: EventChannel.EventSink? = null
    private var pendingVpnResult: MethodChannel.Result? = null
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1010

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            lifecycleScope.launch { handleMethodCall(call, result) }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STATUS_CHANNEL)
                .setStreamHandler(
                        object : EventChannel.StreamHandler {
                            override fun onListen(
                                    arguments: Any?,
                                    events: EventChannel.EventSink?
                            ) {
                                eventSink = events
                                sendVpnStatusToFlutter("disconnected")
                            }
                            override fun onCancel(arguments: Any?) {
                                eventSink = null
                            }
                        }
                )
    }
    private fun grantNotificationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
            )
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        grantNotificationPermission()
    }

    private suspend fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "connect" -> connectVpn(result)
                "disconnect" -> disconnectVpn(result)
                "prepareVPN" -> prepareVpn(result)
                "isVPNPrepared" -> prepareVpn(result)
                "getVpnStatus" -> getVpnStatus(result)
                "grantVpnPermission" -> grantVpnPermission(result)
                // Legacy methods - return success for compatibility
                "startTun2socks" -> result.success(null)
                "isTunnelRunning" -> result.success(false)
                "stopTun2Socks" -> result.success(true)
                "calculatePing" -> result.success(0)
                "getFlag" -> result.success("xx")
                "startVPN" -> result.success(true)
                "stopVPN" -> result.success(true)
                "setAsnName" -> result.success("success")
                "setTimezone" -> result.success(true)
                "getFlowLine" -> result.success("")
                "setConnectionMethod" -> result.success(true)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling method call: ${call.method}", e)
            result.error("METHOD_ERROR", "Error executing ${call.method}", e.message)
        }
    }

    private suspend fun prepareVpn(result: MethodChannel.Result) {
        val vpnIntent = VpnService.prepare(this)
        if (vpnIntent != null) {
            result.success(false)
        } else {
            result.success(true)
        }
    }

    private fun connectVpn(result: MethodChannel.Result) {
        pendingVpnResult = result

        val vpnIntent = VpnService.prepare(this)
        if (vpnIntent != null) {
            try {
                startActivityForResult(vpnIntent, VPN_REQUEST_CODE)
            } catch (e: Exception) {
                result.error("VPN_PERMISSION_ERROR", "Failed to request VPN permission", e.message)
            }
        } else {
            sendVpnStatusToFlutter("connected")
            result.success(true)
        }
    }

    private fun grantVpnPermission(result: MethodChannel.Result) {
        try {
            val vpnIntent = VpnService.prepare(this)
            if (vpnIntent != null) {
                // store the result to respond later
                pendingVpnResult = result
                startActivityForResult(vpnIntent, VPN_REQUEST_CODE)
            } else {
                // permission already granted
                result.success(true)
            }
        } catch (e: SecurityException) {
            // Samsung devices sometimes throw SecurityException
            Log.e(TAG, "SecurityException requesting VPN permission", e)
            result.error("VPN_PERMISSION_DENIED", "VPN permission denied", e.message)
        } catch (e: Exception) {
            Log.e(TAG, "Exception requesting VPN permission", e)
            result.error("VPN_PERMISSION_ERROR", "Failed to request VPN permission", e.message)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == VPN_REQUEST_CODE) {
            val res = pendingVpnResult ?: return
            pendingVpnResult = null

            if (resultCode == Activity.RESULT_OK) {
                sendVpnStatusToFlutter("connected")
                res.success(true)
            } else {
                sendVpnStatusToFlutter("disconnected")
                res.success(false)
            }
        }
    }

    private fun disconnectVpn(result: MethodChannel.Result) =
            try {
                sendVpnStatusToFlutter("disconnected")
                result.success(true)
            } catch (e: Exception) {
                result.error("VPN_STOP_ERROR", "Failed to stop VPN", e.message)
            }

    private fun getVpnStatus(result: MethodChannel.Result) =
            try {
                result.success("disconnected")
            } catch (e: Exception) {
                result.error("GET_STATUS_ERROR", "Failed to get VPN status", e.message)
            }

    private fun sendVpnStatusToFlutter(status: String) {
        eventSink?.success(mapOf("status" to status))
    }
}