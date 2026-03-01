package com.example.taskmanager

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.taskmanager/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "refreshWidget") {
                    refreshAllWidgets()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun refreshAllWidgets() {
        val manager = AppWidgetManager.getInstance(this)
        val ids = manager.getAppWidgetIds(
            ComponentName(this, TaskWidgetProvider::class.java)
        )
         if (ids.isEmpty()) return

        // Directly push RemoteViews to each widget ID — bypasses
        // MIUI launcher's broadcast queue cache so update is instant
        for (id in ids) {
            TaskWidgetProvider.updateWidget(this, manager, id)
        }
    }
}