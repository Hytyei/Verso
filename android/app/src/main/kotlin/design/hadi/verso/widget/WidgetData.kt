package design.hadi.verso.widget

import android.content.Context
import android.content.SharedPreferences
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import design.hadi.verso.R
import org.json.JSONObject

/** One project as the app wrote it into the widget snapshot (lib/widgets/widget_snapshot.dart). */
data class WidgetProject(
    val id: String,
    val name: String,
    val env: String,
    val slot: Int,
    val customColor: Int?,
    val versionId: String,
    val versionName: String,
    val done: Int,
    val total: Int,
    val open: List<Pair<String, String>>,
)

object WidgetData {
    const val SNAPSHOT = "snapshot"
    fun projectKey(widgetId: Int) = "widget_project_$widgetId"

    fun projects(prefs: SharedPreferences): List<WidgetProject> {
        val raw = prefs.getString(SNAPSHOT, null) ?: return emptyList()
        return try {
            val arr = JSONObject(raw).getJSONArray("projects")
            (0 until arr.length()).map { i ->
                val p = arr.getJSONObject(i)
                val v = p.getJSONObject("version")
                val open = p.getJSONArray("open")
                WidgetProject(
                    id = p.getString("id"),
                    name = p.getString("name"),
                    env = p.optString("env"),
                    slot = p.optInt("slot", 0),
                    customColor = if (p.isNull("custom")) null else p.getLong("custom").toInt(),
                    versionId = v.getString("id"),
                    versionName = v.getString("name"),
                    done = v.getInt("done"),
                    total = v.getInt("total"),
                    open = (0 until open.length()).map { j ->
                        val t = open.getJSONObject(j)
                        t.getString("id") to t.getString("title")
                    },
                )
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** The widget's chosen project, else the last one opened in the app, else the first. */
    fun projectFor(prefs: SharedPreferences, widgetId: Int): WidgetProject? {
        val all = projects(prefs)
        if (all.isEmpty()) return null
        val chosen = prefs.getString(projectKey(widgetId), null)
        val last = try {
            JSONObject(prefs.getString(SNAPSHOT, "{}")!!).optString("last")
        } catch (e: Exception) {
            ""
        }
        return all.firstOrNull { it.id == chosen } ?: all.firstOrNull { it.id == last } ?: all.first()
    }

    fun isDark(context: Context) =
        (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES

    /** The project's color in the current theme (palette slots differ in light and dark, as in the app). */
    fun accent(context: Context, p: WidgetProject): Int {
        p.customColor?.let { return it }
        val ids = intArrayOf(R.color.widget_accent_0, R.color.widget_accent_1, R.color.widget_accent_2, R.color.widget_accent_3)
        return context.getColor(ids[p.slot.coerceIn(0, 3)])
    }

    /** A progress ring as a bitmap (RemoteViews can't draw arcs). */
    fun ring(context: Context, sizeDp: Int, done: Int, total: Int, accent: Int): Bitmap {
        val d = context.resources.displayMetrics.density
        val px = (sizeDp * d).toInt().coerceAtLeast(8)
        val bmp = Bitmap.createBitmap(px, px, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val stroke = 3.2f * d
        val r = RectF(stroke / 2, stroke / 2, px - stroke / 2, px - stroke / 2)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = stroke
            strokeCap = Paint.Cap.ROUND
        }
        paint.color = context.getColor(R.color.widget_track)
        c.drawArc(r, 0f, 360f, false, paint)
        if (total > 0 && done > 0) {
            paint.color = accent
            c.drawArc(r, -90f, 360f * done / total, false, paint)
        }
        return bmp
    }

    fun withAlpha(color: Int, alpha: Int) = Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))
}
