package com.jason.adobe_demo_app.utils

import android.util.Log

class Logger {
    private var debugEnabled = false
    private var APP_NAME = "JasonAdobeDemo"

    companion object {
        private var instance: Logger? = null

        fun getInstance(): Logger {
            if (instance == null) {
                instance = Logger()
            }
            return instance!!
        }
        fun debug(message: String) {
            getInstance().debug(message)
        }

        fun info(message: String) {
            getInstance().info(message)
        }

        fun warn(message: String) {
            getInstance().warn(message)
        }

        fun error(message: String) {
            getInstance().error(message)
        }
    }

    fun debug(message: String) {
        Log.d(APP_NAME, message)
    }

    fun info(message: String) {
        Log.i(APP_NAME, message)
    }

    fun warn(message: String) {
        Log.w(APP_NAME, message)
    }

    fun error(message: String) {
        Log.e(APP_NAME, message)
    }
}