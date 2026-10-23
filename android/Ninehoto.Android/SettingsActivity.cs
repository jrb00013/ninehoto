using System;
using Android.App;
using Android.OS;
using Android.Widget;
using AndroidX.AppCompat.App;
using Ninehoto.Droid.Utilities;

namespace Ninehoto.Droid
{
    [Activity(Label = "Settings")]
    public class SettingsActivity : AppCompatActivity
    {
        private enum ThumbnailQuality { Low, Medium, High }

        private const string KeyHaptic = "haptic_feedback";
        private const string KeyQuality = "thumbnail_quality";
        private const string Tag = "ninehoto";

        private Android.Content.ISharedPreferences _prefs;

        private Switch _hapticSwitch;
        private RadioGroup _qualityGroup;
        private RadioGroup _sortGroup;
        private Switch _debugLoggingSwitch;
        private Switch _perfMetricsSwitch;
        private TextView _versionText;
        private Button _resetStatsButton;
        private Button _clearCacheButton;

        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.settings_activity);

            _prefs = Application.Context.GetSharedPreferences("ninehoto_prefs", Android.Content.FileCreationMode.Private);

            InitializeViews();
            LoadSettings();
            SetupListeners();
        }

        private void InitializeViews()
        {
            _hapticSwitch = FindViewById<Switch>(Resource.Id.switch_haptic);
            _qualityGroup = FindViewById<RadioGroup>(Resource.Id.radio_thumbnail_quality);
            _sortGroup = FindViewById<RadioGroup>(Resource.Id.radio_sort_order);
            _debugLoggingSwitch = FindViewById<Switch>(Resource.Id.switch_debug_logging);
            _perfMetricsSwitch = FindViewById<Switch>(Resource.Id.switch_perf_metrics);
            _versionText = FindViewById<TextView>(Resource.Id.text_version);
            _resetStatsButton = FindViewById<Button>(Resource.Id.btn_reset_stats);
            _clearCacheButton = FindViewById<Button>(Resource.Id.btn_clear_cache);

            var toolbar = FindViewById<AndroidX.AppCompat.Widget.Toolbar>(Resource.Id.toolbar);
            if (toolbar != null)
            {
                toolbar.Title = GetString(Resource.String.settings);
                toolbar.SetNavigationIcon(Resource.Drawable.ic_arrow_back);
                toolbar.NavigationClick += (s, e) => Finish();
            }
        }

        private void LoadSettings()
        {
            _hapticSwitch.Checked = _prefs.GetBoolean(KeyHaptic, true);

            switch ((ThumbnailQuality)_prefs.GetInt(KeyQuality, (int)ThumbnailQuality.Medium))
            {
                case ThumbnailQuality.Low:
                    _qualityGroup.Check(Resource.Id.radio_quality_low);
                    break;
                case ThumbnailQuality.High:
                    _qualityGroup.Check(Resource.Id.radio_quality_high);
                    break;
                default:
                    _qualityGroup.Check(Resource.Id.radio_quality_medium);
                    break;
            }

            _debugLoggingSwitch.Checked = FeatureFlags.Instance.IsDebugLoggingEnabled;
            _perfMetricsSwitch.Checked = FeatureFlags.Instance.IsPerformanceMetricsEnabled;

            try
            {
                var version = PackageManager.GetPackageInfo(PackageName, 0).VersionName;
                _versionText.Text = version;
            }
            catch
            {
                _versionText.Text = "1.0.0";
            }
        }

        private void SetupListeners()
        {
            _hapticSwitch.CheckedChange += (s, e) =>
            {
                _prefs.Edit().PutBoolean(KeyHaptic, e.IsChecked).Apply();
                Android.Util.Log.Info(Tag, $"Haptic feedback: {e.IsChecked}");
            };

            _qualityGroup.CheckedChange += (s, e) =>
            {
                var quality = e.CheckedId switch
                {
                    Resource.Id.radio_quality_low => ThumbnailQuality.Low,
                    Resource.Id.radio_quality_high => ThumbnailQuality.High,
                    _ => ThumbnailQuality.Medium
                };
                _prefs.Edit().PutInt(KeyQuality, (int)quality).Apply();
                Android.Util.Log.Info(Tag, $"Thumbnail quality set to: {quality}");
            };

            _debugLoggingSwitch.CheckedChange += (s, e) =>
            {
                FeatureFlags.Instance.SetFeature("debug_logging", e.IsChecked);
            };

            _perfMetricsSwitch.CheckedChange += (s, e) =>
            {
                FeatureFlags.Instance.SetFeature("performance_metrics", e.IsChecked);
            };

            _resetStatsButton.Click += (s, e) =>
            {
                _prefs.Edit().Remove("statistics").Apply();
                Android.Util.Log.Info(Tag, "Statistics reset");
                Toast.MakeText(this, "Statistics reset", ToastLength.Short).Show();
            };

            _clearCacheButton.Click += (s, e) =>
            {
                ThumbnailCache.Instance.Clear();
                Android.Util.Log.Info(Tag, "Cache cleared");
                Toast.MakeText(this, "Cache cleared", ToastLength.Short).Show();
            };
        }
    }
}