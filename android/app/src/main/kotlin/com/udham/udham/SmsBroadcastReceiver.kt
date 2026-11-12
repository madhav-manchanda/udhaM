package com.udham.udham

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

class SmsBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        for (msg in messages) {
            val sender = msg.originatingAddress ?: ""
            val body = msg.messageBody ?: ""
            val date = msg.timestampMillis

            // 1. If MainActivity is alive, route to Flutter pipeline
            val activity = MainActivity.activeInstance
            if (activity != null) {
                activity.notifySmsReceived(sender, body, date)
            } else {
                // 2. Background handling when app is inactive
                if (isLikelyBankTransaction(sender, body)) {
                    val bankName = extractBankName(sender)
                    NotificationHelper.showDetectedTransactionNotification(
                        context = context,
                        candidateId = "",
                        bankName = bankName,
                        direction = null,
                        amountFormatted = null,
                        maskedAccount = null,
                        timestamp = date,
                        isParseable = false
                    )
                }
            }
        }
    }

    private fun isLikelyBankTransaction(sender: String, body: String): Boolean {
        val cleanSender = sender.trim().uppercase()
        val cleanBody = body.lowercase()

        // Ignore OTP messages
        if (cleanBody.contains("otp") || cleanBody.contains("one time password") || cleanBody.contains("verification code")) {
            return false
        }

        val hasTxKeywords = cleanBody.contains("debited") ||
                cleanBody.contains("credited") ||
                cleanBody.contains("sent") ||
                cleanBody.contains("received") ||
                cleanBody.contains("spent") ||
                cleanBody.contains("vpa") ||
                cleanBody.contains("upi")

        val hasCurrency = cleanBody.contains("rs.") ||
                cleanBody.contains("rs ") ||
                cleanBody.contains("inr") ||
                cleanBody.contains("₹")

        return (hasTxKeywords && hasCurrency) || cleanSender.length >= 6
    }

    private fun extractBankName(sender: String): String {
        val clean = sender.trim().uppercase()
        return when {
            clean.contains("HDFC") -> "HDFC Bank"
            clean.contains("SBI") -> "State Bank of India"
            clean.contains("ICICI") -> "ICICI Bank"
            clean.contains("AXIS") -> "Axis Bank"
            clean.contains("KBL") -> "Karnataka Bank"
            clean.contains("KOTAK") -> "Kotak Mahindra"
            clean.contains("PNB") -> "Punjab National Bank"
            clean.contains("BOB") -> "Bank of Baroda"
            clean.contains("CANARA") -> "Canara Bank"
            clean.contains("PAYTM") -> "Paytm Bank"
            else -> "Bank"
        }
    }
}
