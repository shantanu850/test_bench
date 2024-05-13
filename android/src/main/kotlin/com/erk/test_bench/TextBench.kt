package com.erk.test_bench

import io.flutter.plugin.common.EventChannel

class TestBench {
    companion object TestBench {
        private const val LOG_TYPE_DEBUG = "d"
        private const val LOG_TYPE_INFO = "i"
        private const val LOG_TYPE_ERROR = "e"

        private var eventChannel: EventChannel? = null
        private var eventSink: EventChannel.EventSink? = null

        fun init(eventChannel: EventChannel) {
            this.eventChannel = eventChannel
            this.eventChannel?.setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                        eventSink = events

                    }

                    override fun onCancel(arguments: Any?) {

                    }
                })

        }

        fun d(message: Any) {
            eventSink?.success(listOf(LOG_TYPE_DEBUG, message))
        }

        fun i(message: Any) {
            eventSink?.success(listOf(LOG_TYPE_INFO, message))
        }

        fun e(message: Any) {
            eventSink?.success(listOf(LOG_TYPE_ERROR, message))
        }
    }

}