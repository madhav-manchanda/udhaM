package com.udham.udham

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object NotificationHelper {
    const val CHANNEL_ID = "udham_detected_transactions"
    private const val CHANNEL_NAME = "Detected Transactions"
    private const val CHANNEL_DESCRIPTION = "Alerts when a bank transaction SMS is detected on-device"

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = CHANNEL_DESCRIPTION
                enableLights(true)
                enableVibration(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PRIVATE
            }
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            manager?.createNotificationChannel(channel)
        }
    }

    fun areNotificationsEnabled(context: Context): Boolean {
        return NotificationManagerCompat.from(context).areNotificationsEnabled()
    }

    fun showDetectedTransactionNotification(
        context: Context,
        candidateId: String,
        bankName: String?,
        direction: String?,
        amountFormatted: String?,
        maskedAccount: String?,
        timestamp: Long,
        isParseable: Boolean
    ) {
        createNotificationChannel(context)

        val targetRoute = if (candidateId.isNotBlank()) "/inbox/$candidateId" else "/inbox"
        // Use a plain launch intent with only the route extra — no ACTION_VIEW / URI data,
        // so GoRouter does not intercept the URI and try to match it as a path.
        val intent = Intent(context, MainActivity::class.java).apply {
            putExtra("route", targetRoute)
            putExtra("candidateId", candidateId)
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val stableNotificationId = if (candidateId.isNotBlank()) {
            candidateId.hashCode()
        } else {
            (System.currentTimeMillis() % 100000).toInt()
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            stableNotificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val title: String
        val body: String

        if (isParseable && !amountFormatted.isNullOrEmpty()) {
            val cleanBank = if (!bankName.isNullOrBlank()) bankName else "Bank"
            val dirLabel = when (direction?.lowercase()) {
                "credit" -> "Credit"
                else -> "Debit"
            }
            title = "$cleanBank • $dirLabel Detected"

            val acctStr = if (!maskedAccount.isNullOrBlank()) " from acct $maskedAccount" else ""
            val dirVerb = when (direction?.lowercase()) {
                "credit" -> "credited to"
                else -> "debited"
            }
            body = "$amountFormatted $dirVerb$acctStr. Tap to review and confirm."
        } else {
            title = "Bank Transaction Detected"
            body = "New bank transaction message detected. Review in UdhaM."
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_udham)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setWhen(if (timestamp > 0) timestamp else System.currentTimeMillis())

        try {
            val notificationManager = NotificationManagerCompat.from(context)
            if (notificationManager.areNotificationsEnabled()) {
                notificationManager.notify(stableNotificationId, builder.build())
            }
        } catch (_: SecurityException) {
            // Permission denied or revoked
        }
    }
}
