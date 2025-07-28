package com.example.emotion_gpt_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import kotlin.random.Random

class QuoteWidget : AppWidgetProvider() {

    private val quotes = listOf(
        "✨ Ты способен на большее!",
        "🚀 Вперёд к мечтам!",
        "🌟 Сегодня твой день!",
        "🔥 Не сдавайся!",
        "💪 У тебя всё получится!",
        "😊 Ты — огонь!"
    )

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    private val emojis = listOf("✨", "🚀", "🌟", "🔥", "💪", "😊")

    private fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.quote_widget)

        val index = Random.nextInt(quotes.size)
        val quote = quotes[index]
        val emoji = emojis[index]

        views.setTextViewText(R.id.emoji, emoji)
        views.setTextViewText(R.id.quote_text, quote)

        // Обновление при тапе — перезагрузка виджета
        val intent = Intent(context, QuoteWidget::class.java)
        intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        val ids = AppWidgetManager.getInstance(context).getAppWidgetIds(ComponentName(context, QuoteWidget::class.java))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        val pendingIntent = PendingIntent.getBroadcast(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)  // Обработчик на весь виджет

        manager.updateAppWidget(widgetId, views)
    }

}
