using System;
using System.Collections.Generic;
using System.Linq;
using Android.App;
using Android.OS;
using Android.Views;
using Android.Widget;
using AndroidX.AppCompat.App;
using Ninehoto.Android.Models;

namespace Ninehoto.Android
{
    [Activity(Label = "Statistics")]
    public class StatisticsActivity : AppCompatActivity
    {
        private TextView _totalSwipesText;
        private TextView _deletedText;
        private TextView _keptText;
        private TextView _deleteRateText;
        private TextView _avgSwipesText;
        private TextView _totalTimeText;
        private LinearLayout _sessionsContainer;

        private StatisticsTracker? _tracker;

        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.statistics_activity);

            InitializeViews();
            LoadStatistics();
        }

        private void InitializeViews()
        {
            _totalSwipesText = FindViewById<TextView>(Resource.Id.text_total_swipes);
            _deletedText = FindViewById<TextView>(Resource.Id.text_deleted);
            _keptText = FindViewById<TextView>(Resource.Id.text_kept);
            _deleteRateText = FindViewById<TextView>(Resource.Id.text_delete_rate);
            _avgSwipesText = FindViewById<TextView>(Resource.Id.text_avg_swipes);
            _totalTimeText = FindViewById<TextView>(Resource.Id.text_total_time);
            _sessionsContainer = FindViewById<LinearLayout>(Resource.Id.sessions_container);

            var toolbar = FindViewById<AndroidX.AppCompat.Widget.Toolbar>(Resource.Id.toolbar);
            if (toolbar != null)
            {
                toolbar.Title = GetString(Resource.String.statistics);
                toolbar.SetNavigationIcon(Resource.Drawable.ic_arrow_back);
                toolbar.NavigationClick += (s, e) => Finish();
            }
        }

        private void LoadStatistics()
        {
            var prefs = Application.Context.GetSharedPreferences("ninehoto_prefs", Android.Content.FileCreationMode.Private);
            _tracker = new StatisticsTracker(prefs);

            var totalStats = _tracker.GetTotalStatistics();

            _totalSwipesText.Text = totalStats.SwipeCount.ToString();
            _deletedText.Text = totalStats.DeleteCount.ToString();
            _keptText.Text = totalStats.KeepCount.ToString();
            _deleteRateText.Text = $"{totalStats.DeleteRate:F1}%";
            _avgSwipesText.Text = $"{totalStats.AverageSwipesPerMinutes:F1}/min";
            _totalTimeText.Text = totalStats.FormattedDuration;

            var sessions = _tracker.GetAllSessions();
            DisplaySessions(sessions.Take(10).ToList());
        }

        private void DisplaySessions(List<SessionStatistics> sessions)
        {
            if (sessions.Count == 0)
            {
                var emptyText = new TextView(this)
                {
                    Text = "No sessions yet",
                    TextAlignment = TextAlignment.Center,
                    SetTextColor(Android.Graphics.Color.Gray)
                };
                _sessionsContainer.AddView(emptyText);
                return;
            }

            foreach (var session in sessions)
            {
                var sessionView = LayoutInflater.Inflate(Resource.Layout.statistics_session_item, _sessionsContainer, false);

                var dateText = sessionView.FindViewById<TextView>(Resource.Id.text_session_date);
                var swipesText = sessionView.FindViewById<TextView>(Resource.Id.text_session_swipes);
                var deletedText = sessionView.FindViewById<TextView>(Resource.Id.text_session_deleted);
                var keptText = sessionView.FindViewById<TextView>(Resource.Id.text_session_kept);
                var durationText = sessionView.FindViewById<TextView>(Resource.Id.text_session_duration);

                dateText.Text = session.SessionDate.ToString("g");
                swipesText.Text = $"{session.SwipeCount} swipes";
                deletedText.Text = $"{session.DeleteCount} deleted";
                keptText.Text = $"{session.KeepCount} kept";
                durationText.Text = session.FormattedDuration;

                _sessionsContainer.AddView(sessionView);
            }
        }
    }
}