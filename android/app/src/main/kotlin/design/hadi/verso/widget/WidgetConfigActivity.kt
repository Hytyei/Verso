package design.hadi.verso.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.ListView
import design.hadi.verso.R
import es.antonborri.home_widget.HomeWidgetPlugin

/** Asked when a widget is placed (and on reconfigure): which project should it follow? */
class WidgetConfigActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val widgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        // Backing out leaves the widget unplaced.
        setResult(RESULT_CANCELED, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        title = getString(R.string.widget_pick_project)
        val prefs = HomeWidgetPlugin.getData(this)
        val projects = WidgetData.projects(prefs)
        val labels = listOf(getString(R.string.widget_follow_last)) +
            projects.map { if (it.env.isEmpty()) it.name else "${it.name}  ·  ${it.env}" }
        val list = ListView(this)
        list.adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, labels)
        list.setOnItemClickListener { _, _, pos, _ ->
            val edit = prefs.edit()
            if (pos == 0) edit.remove(WidgetData.projectKey(widgetId)) else edit.putString(WidgetData.projectKey(widgetId), projects[pos - 1].id)
            edit.apply()
            VersoWidgets.refreshAll(this)
            setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
            finish()
        }
        setContentView(list)
    }
}
