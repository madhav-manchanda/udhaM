package com.udham.udham

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        const val CHANNEL_NAME = "com.udham.udham/sms"
        const val SMS_PERMISSION_CODE = 4421
        const val NOTIFICATION_PERMISSION_CODE = 4422

        var activeInstance: MainActivity? = null
    }

    private var pendingSmsResult: MethodChannel.Result? = null
    private var pendingNotificationResult: MethodChannel.Result? = null
    private var methodChannel: MethodChannel? = null
    private var initialNotificationRoute: String? = null

    private val smsReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                for (msg in messages) {
                    val sender = msg.originatingAddress ?: ""
                    val body = msg.messageBody ?: ""
                    val date = msg.timestampMillis
                    notifySmsReceived(sender, body, date)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activeInstance = this
        NotificationHelper.createNotificationChannel(this)
        handleLaunchIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLaunchIntent(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        if (activeInstance == this) {
            activeInstance = null
        }
        try {
            unregisterReceiver(smsReceiver)
        } catch (_: Exception) {
        }
    }

    fun notifySmsReceived(sender: String, body: String, date: Long) {
        runOnUiThread {
            methodChannel?.invokeMethod(
                "onSmsReceived",
                mapOf(
                    "sender" to sender,
                    "body" to body,
                    "date" to date
                )
            )
        }
    }

    private fun handleLaunchIntent(intent: Intent?) {
        if (intent == null) return

        val route = intent.getStringExtra("route")
            ?: intent.data?.let { uri ->
                if (uri.scheme == "com.udham.udham" && uri.host == "inbox") {
                    val path = uri.path ?: ""
                    "/inbox$path"
                } else null
            }

        if (route != null) {
            if (methodChannel != null) {
                runOnUiThread {
                    methodChannel?.invokeMethod("onNotificationOpened", route)
                }
            } else {
                initialNotificationRoute = route
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    val readGranted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    val receiveGranted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.RECEIVE_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(readGranted && receiveGranted)
                }
                "requestPermissions" -> {
                    val readGranted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                    val receiveGranted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.RECEIVE_SMS
                    ) == PackageManager.PERMISSION_GRANTED

                    if (readGranted && receiveGranted) {
                        result.success(true)
                    } else {
                        pendingSmsResult = result
                        val permissions = arrayOf(
                            Manifest.permission.READ_SMS,
                            Manifest.permission.RECEIVE_SMS
                        )
                        ActivityCompat.requestPermissions(
                            this,
                            permissions,
                            SMS_PERMISSION_CODE
                        )
                    }
                }
                "checkNotificationPermission" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED
                    } else {
                        NotificationHelper.areNotificationsEnabled(this)
                    }
                    result.success(granted)
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val granted = ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.POST_NOTIFICATIONS
                        ) == PackageManager.PERMISSION_GRANTED
                        if (granted) {
                            result.success(true)
                        } else {
                            pendingNotificationResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                NOTIFICATION_PERMISSION_CODE
                            )
                        }
                    } else {
                        result.success(NotificationHelper.areNotificationsEnabled(this))
                    }
                }
                "showTransactionNotification" -> {
                    val candidateId = call.argument<String>("candidateId") ?: ""
                    val bankName = call.argument<String>("bankName")
                    val direction = call.argument<String>("direction")
                    val amountFormatted = call.argument<String>("amountFormatted")
                    val maskedAccount = call.argument<String>("maskedAccount")
                    val timestamp = (call.argument<Number>("timestamp"))?.toLong() ?: System.currentTimeMillis()
                    val isParseable = call.argument<Boolean>("isParseable") ?: false

                    NotificationHelper.showDetectedTransactionNotification(
                        context = this,
                        candidateId = candidateId,
                        bankName = bankName,
                        direction = direction,
                        amountFormatted = amountFormatted,
                        maskedAccount = maskedAccount,
                        timestamp = timestamp,
                        isParseable = isParseable
                    )
                    result.success(true)
                }
                "getInitialNotificationRoute" -> {
                    val route = initialNotificationRoute
                    initialNotificationRoute = null
                    result.success(route)
                }
                "readInboxSms" -> {
                    val limit = call.argument<Int>("limit") ?: 100
                    try {
                        val smsList = readSmsFromInbox(limit)
                        result.success(smsList)
                    } catch (e: Exception) {
                        result.error("READ_SMS_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Deliver any pending notification route caught during onCreate
        initialNotificationRoute?.let { route ->
            runOnUiThread {
                methodChannel?.invokeMethod("onNotificationOpened", route)
            }
        }

        try {
            val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(smsReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                registerReceiver(smsReceiver, filter)
            }
        } catch (_: Exception) {
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            SMS_PERMISSION_CODE -> {
                val allGranted = grantResults.isNotEmpty() && grantResults.all {
                    it == PackageManager.PERMISSION_GRANTED
                }
                pendingSmsResult?.success(allGranted)
                pendingSmsResult = null
            }
            NOTIFICATION_PERMISSION_CODE -> {
                val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
                pendingNotificationResult?.success(granted)
                pendingNotificationResult = null
            }
        }
    }

    private fun readSmsFromInbox(limit: Int): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        val readGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_SMS
        ) == PackageManager.PERMISSION_GRANTED
        if (!readGranted) return list

        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date")
        val cursor = contentResolver.query(
            uri,
            projection,
            null,
            null,
            "date DESC LIMIT $limit"
        )
        cursor?.use {
            val idIndex = it.getColumnIndex("_id")
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")

            while (it.moveToNext()) {
                val id = if (idIndex != -1) it.getString(idIndex) else ""
                val address = if (addressIndex != -1) it.getString(addressIndex) else ""
                val body = if (bodyIndex != -1) it.getString(bodyIndex) else ""
                val date = if (dateIndex != -1) it.getLong(dateIndex) else 0L

                if (body.isNotEmpty()) {
                    list.add(
                        mapOf(
                            "id" to id,
                            "address" to address,
                            "body" to body,
                            "date" to date
                        )
                    )
                }
            }
        }
        return list
    }
}
