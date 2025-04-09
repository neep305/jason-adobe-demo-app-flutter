package com.jason.adobe_demo_app

import android.os.Bundle
import com.adobe.marketing.mobile.AEPMessagingService
import com.adobe.marketing.mobile.CampaignClassic
import com.adobe.marketing.mobile.LoggingMode
import com.adobe.marketing.mobile.MobileCore
import com.google.firebase.messaging.RemoteMessage
import com.jason.adobe_demo_app.utils.Logger
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val ENVIRONMENT_FILE_ID = "1a2e5738b89a/37491cf23176/launch-6c40c5052086-development"
    private val CHANNEL_NAME = "com.jason.adobe_demo_app/push"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Adobe SDK Initialization
        MobileCore.setApplication(application)
        MobileCore.setLogLevel(LoggingMode.DEBUG)
        MobileCore.configureWithAppID(ENVIRONMENT_FILE_ID)

        MobileCore.registerExtensions(
            listOf(
                CampaignClassic.EXTENSION,
//                Lifecycle.EXTENSION,
//                Identity.EXTENSION,
//                Analytics.EXTENSION,
//                Edge.EXTENSION,
//                Signal.EXTENSION,
//                Target.EXTENSION
            )
        ) {
            Logger.debug("[MainActivity] Adobe Mobile Core Initialized")
        }
    }

    override fun onResume() {
        super.onResume()
        Logger.debug("✅ [MainActivity] onResume called...")
    }

    override fun onPause() {
        super.onPause()
        Logger.debug("✅ [MainActivity] onPause called...")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "registerPushToken" -> {
                    val token = call.argument<String>("token")
                    val guid = call.argument<String>("guid")
                    val additionalParams = call.argument<Map<String, Any>>("additionalParameters")

                    if (!token.isNullOrEmpty()) {
                        CampaignClassic.registerDevice(token, guid, additionalParams)
                        Logger.debug("✅ CampaignClassic.registerDevice called - token: $token")
                        val resultMap = mapOf(
                            "status" to "success",
                            "message" to "CampaignClassic.registerDevice called",
                            "token" to token
                        )
                        result.success(resultMap)
                    } else {
                        result.error("No Token", "FCM Token is null or empty", null)
                    }
                }

                "trackNotificationReceive" -> {
                    val data = call.argument<Map<String, Any>>("data")

                    if (data != null) {
                        if (data.isNotEmpty()) {
                            val message = RemoteMessage(Bundle().apply {
                                data.forEach { (key, value) ->
                                    if (value is String) putString(key, value)
                                }
                            })
                            Logger.debug("✅ [MainActivity] trackNotificationReceive called - message.data: ${message.data}")

                            val payloadData = message.data

                            // Check data whether it contains _mId, _dId or not
                            if (payloadData["_mId"].isNullOrEmpty() or payloadData["_dId"].isNullOrEmpty()) {
                                result.error("Invalid _mId or _dId Data", "_mId or _dId is null or empty", null)
                                return@setMethodCallHandler
                            }
                            // _mId, _dId만 original message data에서 추출하여 trackInfo로 전송
                            val trackInfo: MutableMap<String, String?> = HashMap()
                            trackInfo["_mId"] = payloadData["_mId"]
                            trackInfo["_dId"] = payloadData["_dId"]

                            CampaignClassic.trackNotificationReceive(trackInfo)
                            Logger.debug("✅ [MainActivity] CampaignClassic.trackNotificationReceive sent")

                            // Adobe Rich Push Template: Creating a Rich Push Message UI (True: Rich Push, False: Default Push)
                            if (AEPMessagingService.handleRemoteMessage(this, message)) {
                                val resultMap = mapOf(
                                    "status" to "success",
                                    "message" to "trackNotificationReceive called - Rich Push",
                                    "trackInfo" to trackInfo
                                )
                                result.success(resultMap)
                            } else {
                                // Make own Template UI
                                val resultMap = mapOf(
                                    "status" to "success",
                                    "message" to "trackNotificationReceive called - Default Push",
                                    "trackInfo" to trackInfo
                                )
                                result.success(resultMap)
                            }
                        }
                    }
                }

                "trackNotificationClick" -> {
                    val data = call.argument<Map<String, Any>>("data")
                    if (data != null) {
                        Logger.debug("✅ [MainActivity] trackNotificationClick - data: $data")

                        val payloadData = data.mapNotNull { (key, value) ->
                            if (value is String) key to value else null
                        }.toMap()
                        // Creating a trackingInfo using payload data(_mId, _dId) to send to Adobe
                        val trackInfo: MutableMap<String, String?> = HashMap()
                        trackInfo["_mId"] = payloadData["_mId"]
                        trackInfo["_dId"] = payloadData["_dId"]
                        CampaignClassic.trackNotificationClick(trackInfo)

                        Logger.debug("✅ [MainActivity] CampaignClassic.trackNotificationClick called. trackInfo: $trackInfo")
                        val resultMap = mapOf(
                            "status" to "success",
                            "message" to "trackNotificationClick called",
                            "trackInfo" to trackInfo
                        )
                        result.success(resultMap)
                    } else {
                        result.error("No TrackingNotificationClick Data", "No Payload Data Received", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
