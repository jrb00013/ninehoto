using System;
using Android.App;
using Android.OS;
using Android.Widget;
using AndroidX.AppCompat.App;
using AndroidWebView = Android.Webkit.WebView;

namespace Ninehoto.Android
{
    [Activity(Label = "About")]
    public class AboutActivity : AppCompatActivity
    {
        private TextView _versionText;
        private TextView _descriptionText;

        protected override void OnCreate(Bundle savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.about_activity);

            InitializeViews();
            LoadData();
        }

        private void InitializeViews()
        {
            _versionText = FindViewById<TextView>(Resource.Id.text_version);
            _descriptionText = FindViewById<TextView>(Resource.Id.text_description);

            var toolbar = FindViewById<AndroidX.AppCompat.Widget.Toolbar>(Resource.Id.toolbar);
            if (toolbar != null)
            {
                toolbar.Title = GetString(Resource.String.about);
                toolbar.SetNavigationIcon(Resource.Drawable.ic_arrow_back);
                toolbar.NavigationClick += (s, e) => Finish();
            }
        }

        private void LoadData()
        {
            try
            {
                var packageInfo = PackageManager.GetPackageInfo(PackageName, 0);
                _versionText.Text = $"Version {packageInfo.VersionName} ({packageInfo.VersionCode})";
            }
            catch
            {
                _versionText.Text = "Version 1.0.0";
            }

            _descriptionText.Text = GetString(Resource.String.main_blurb);
        }
    }
}