package design.hadi.verso.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import design.hadi.verso.MainActivity
import design.hadi.verso.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

private val ROWS = intArrayOf(R.id.row0, R.id.row1, R.id.row2, R.id.row3, R.id.row4, R.id.row5, R.id.row6, R.id.row7)
private val CHECKS = intArrayOf(R.id.check0, R.id.check1, R.id.check2, R.id.check3, R.id.check4, R.id.check5, R.id.check6, R.id.check7)
private val TITLES = intArrayOf(R.id.title0, R.id.title1, R.id.title2, R.id.title3, R.id.title4, R.id.title5, R.id.title6, R.id.title7)

private fun openUri(p: WidgetProject?) =
    Uri.parse(if (p == null) "verso://open" else "verso://open?project=${p.id}&version=${p.versionId}")

/** Resizable: project, version, ring, then as many open tasks as fit; their checkboxes tick them. */
class CurrentVersionWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (id in appWidgetIds) render(context, appWidgetManager, id, widgetData)
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) {
        render(context, appWidgetManager, appWidgetId, HomeWidgetPlugin.getData(context))
    }

    companion object {
        fun render(context: Context, mgr: AppWidgetManager, id: Int, prefs: SharedPreferences) {
            val views = RemoteViews(context.packageName, R.layout.widget_current)
            val p = WidgetData.projectFor(prefs, id)
            views.setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, openUri(p)))
            if (p == null) {
                views.setTextViewText(R.id.project, context.getString(R.string.widget_empty_title))
                views.setTextViewText(R.id.version, context.getString(R.string.widget_empty_body))
                views.setTextViewText(R.id.count, "")
                views.setViewVisibility(R.id.ring, View.GONE)
                views.setViewVisibility(R.id.empty, View.GONE)
                for (r in ROWS) views.setViewVisibility(r, View.GONE)
                mgr.updateAppWidget(id, views)
                return
            }
            val accent = WidgetData.accent(context, p)
            views.setTextViewText(R.id.project, p.name)
            views.setTextViewText(R.id.version, if (p.env.isEmpty()) p.versionName else "${p.versionName} · ${p.env}")
            views.setTextViewText(R.id.count, "${p.done}/${p.total}")
            views.setViewVisibility(R.id.ring, View.VISIBLE)
            views.setImageViewBitmap(R.id.ring, WidgetData.ring(context, 30, p.done, p.total, accent))
            views.setInt(R.id.accent_bar, "setColorFilter", accent)

            // Rows that fit: header ~64 dp, each row ~30 dp.
            val opts = mgr.getAppWidgetOptions(id)
            val h = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 180)
            val fit = ((h - 66) / 30).coerceIn(1, ROWS.size)
            val shown = p.open.take(fit)
            for (i in ROWS.indices) {
                if (i < shown.size) {
                    val (fid, title) = shown[i]
                    views.setViewVisibility(ROWS[i], View.VISIBLE)
                    views.setTextViewText(TITLES[i], title)
                    views.setInt(CHECKS[i], "setColorFilter", accent)
                    val tick = Uri.parse("verso://toggle?feature=$fid")
                    views.setOnClickPendingIntent(CHECKS[i], HomeWidgetBackgroundIntent.getBroadcast(context, tick))
                    views.setOnClickPendingIntent(TITLES[i], HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, openUri(p)))
                } else {
                    views.setViewVisibility(ROWS[i], View.GONE)
                }
            }
            views.setViewVisibility(R.id.empty, if (shown.isEmpty()) View.VISIBLE else View.GONE)
            mgr.updateAppWidget(id, views)
        }
    }
}

/** Small tile: project, version and ring. */
class ProgressGlanceWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (id in appWidgetIds) render(context, appWidgetManager, id, widgetData)
    }

    companion object {
        fun render(context: Context, mgr: AppWidgetManager, id: Int, prefs: SharedPreferences) {
            val views = RemoteViews(context.packageName, R.layout.widget_glance)
            val p = WidgetData.projectFor(prefs, id)
            views.setOnClickPendingIntent(R.id.root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, openUri(p)))
            if (p == null) {
                views.setTextViewText(R.id.project, context.getString(R.string.widget_empty_title))
                views.setTextViewText(R.id.version, "")
                views.setTextViewText(R.id.count, "")
                mgr.updateAppWidget(id, views)
                return
            }
            val accent = WidgetData.accent(context, p)
            views.setTextViewText(R.id.project, p.name)
            views.setTextViewText(R.id.version, p.versionName)
            val pct = if (p.total == 0) 0 else (100 * p.done / p.total)
            views.setTextViewText(R.id.count, "$pct%")
            views.setImageViewBitmap(R.id.ring, WidgetData.ring(context, 44, p.done, p.total, accent))
            mgr.updateAppWidget(id, views)
        }
    }
}

/** Re-renders every placed Verso widget (after the config screen picks a project). */
object VersoWidgets {
    fun refreshAll(context: Context) {
        val mgr = AppWidgetManager.getInstance(context)
        val prefs = HomeWidgetPlugin.getData(context)
        for (id in mgr.getAppWidgetIds(android.content.ComponentName(context, CurrentVersionWidget::class.java))) {
            CurrentVersionWidget.render(context, mgr, id, prefs)
        }
        for (id in mgr.getAppWidgetIds(android.content.ComponentName(context, ProgressGlanceWidget::class.java))) {
            ProgressGlanceWidget.render(context, mgr, id, prefs)
        }
    }
}
