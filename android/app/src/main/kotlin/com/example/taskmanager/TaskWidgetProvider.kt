package com.example.taskmanager

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import com.example.taskmanager.R
import org.json.JSONArray
import org.json.JSONObject

class TaskWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            try {
                updateWidget(context, appWidgetManager, widgetId)
            } catch (e: Exception) {
                Log.e("TaskWidget", "Error updating widget", e)
            }
        }
    }

    companion object {
        private const val TAG = "TaskWidget"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.task_widget)

            // Tap widget → open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, widgetId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            var taskTitle = "No tasks yet"
            var taskDate = ""
            var activeCount = 0

            try {
                val prefs = context.getSharedPreferences(
                    "FlutterSharedPreferences", Context.MODE_PRIVATE
                )

                val rawValue = prefs.getString("flutter.tasks", null)

                if (rawValue != null) {
                    // flutter_shared_preferences stores StringList as:
                    // "VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu![item1, item2, ...]"
                    // We strip everything before the first '[' to get the JSON array
                    val jsonStart = rawValue.indexOf('[')
                    if (jsonStart != -1) {
                        val jsonString = rawValue.substring(jsonStart)
                        val arr = JSONArray(jsonString)

                        for (i in 0 until arr.length()) {
                            // Each element is a JSON string (escaped), parse it
                            val taskJson = arr.getString(i)
                            val task = JSONObject(taskJson)
                            if (!task.optBoolean("isCompleted", false)) {
                                activeCount++
                                if (activeCount == 1) {
                                    taskTitle = task.optString("title", "Task")
                                    val endDate = task.optString("endDate", "")
                                    if (endDate.isNotEmpty()) {
                                        taskDate = "Due ${formatDate(endDate)}"
                                    }
                                }
                            }
                        }
                        Log.d(TAG, "Parsed $activeCount active tasks")
                    }
                }

            } catch (e: Exception) {
                Log.e(TAG, "Error reading tasks", e)
                taskTitle = "Tap to open app"
            }

            val countText = when (activeCount) {
                0 -> "All tasks done!"
                1 -> "1 active task"
                else -> "$activeCount active tasks"
            }

            views.setTextViewText(R.id.widget_task_title, taskTitle)
            views.setTextViewText(R.id.widget_task_date, taskDate)
            views.setTextViewText(R.id.widget_task_count, countText)

            appWidgetManager.updateAppWidget(widgetId, views)
            Log.d(TAG, "Widget updated: $taskTitle")
        }

        private fun formatDate(isoDate: String): String {
            if (isoDate.isEmpty()) return ""
            return try {
                val months = listOf(
                    "Jan","Feb","Mar","Apr","May","Jun",
                    "Jul","Aug","Sep","Oct","Nov","Dec"
                )
                val parts = isoDate.split("-")
                val month = parts[1].toInt()
                val day = parts[2].substring(0, 2).toInt()
                "$day ${months[month - 1]}"
            } catch (e: Exception) {
                ""
            }
        }
    }
}