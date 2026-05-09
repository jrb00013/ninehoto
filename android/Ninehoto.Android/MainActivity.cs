using Android;
using Android.App;
using Android.Content;
using Android.Content.PM;
using Android.Graphics;
using Android.OS;
using Android.Provider;
using Android.Views;
using Android.Widget;
using AndroidX.AppCompat.App;
using AndroidX.Core.Content;
using AlertDialog = AndroidX.AppCompat.App.AlertDialog;
using Uri = Android.Net.Uri;

namespace Ninehoto;

[Activity(
    Label = "@string/app_name",
    MainLauncher = true,
    Theme = "@style/AppTheme",
    ConfigurationChanges = ConfigChanges.Orientation | ConfigChanges.ScreenSize | ConfigChanges.KeyboardHidden)]
public class MainActivity : AppCompatActivity
{
    private const int PermRequestCode = 1001;
    private const int DeleteRequestCode = 1002;
    private const float SwipeThresholdPx = 120f;

    private MediaRepository? _repo;
    private readonly List<MediaItem> _queue = new();
    private readonly HashSet<long> _pendingDeleteIds = new();

    private View? _menuScroll;
    private View? _sessionLayout;
    private ImageView? _cardImage;
    private TextView? _deleteBadge;
    private TextView? _keepBadge;
    private TextView? _markedText;
    private TextView? _remainingText;
    private TextView? _permissionText;
    private ProgressBar? _loadingBar;
    private Button? _startButton;

    private int _index;
    private int _lastDeleteCount;
    private bool _permissionRequestedOnce;

    protected override void OnCreate(Bundle? savedInstanceState)
    {
        base.OnCreate(savedInstanceState);
        SupportActionBar?.Hide();
        SetContentView(Resource.Layout.activity_main);

        _repo = new MediaRepository(this);

        _menuScroll = FindViewById(Resource.Id.menu_scroll);
        _sessionLayout = FindViewById(Resource.Id.session_layout);
        _cardImage = FindViewById<ImageView>(Resource.Id.card_image);
        _deleteBadge = FindViewById<TextView>(Resource.Id.delete_badge);
        _keepBadge = FindViewById<TextView>(Resource.Id.keep_badge);
        _markedText = FindViewById<TextView>(Resource.Id.marked_text);
        _remainingText = FindViewById<TextView>(Resource.Id.remaining_text);
        _permissionText = FindViewById<TextView>(Resource.Id.permission_text);
        _loadingBar = FindViewById<ProgressBar>(Resource.Id.loading_bar);
        _startButton = FindViewById<Button>(Resource.Id.start_button);

        var cap = FindViewById<TextView>(Resource.Id.cap_text);
        cap!.Text = GetString(Resource.String.session_cap, MediaRepository.SessionLimit);

        _startButton!.Click += (_, _) => TryStartSession();
        FindViewById<Button>(Resource.Id.done_button)!.Click += (_, _) => ShowFinishDialog();

        _cardImage!.SetOnTouchListener(new SwipeTouchListener(
            onSwipeLeft: HandleSwipeLeft,
            onSwipeRight: HandleSwipeRight,
            onDrag: UpdateBadges,
            onCancelDrag: HideBadges));

        UpdatePermissionBanner();
        ShowMenu();
    }

    private void UpdatePermissionBanner()
    {
        if (_permissionText == null || _startButton == null)
        {
            return;
        }

        _startButton.Enabled = true;
        if (HasMediaReadPermission())
        {
            _permissionText.Visibility = ViewStates.Gone;
        }
        else if (_permissionRequestedOnce)
        {
            _permissionText.Text = GetString(Resource.String.permission_denied);
            _permissionText.Visibility = ViewStates.Visible;
        }
        else
        {
            _permissionText.Visibility = ViewStates.Gone;
        }
    }

    private bool HasMediaReadPermission()
    {
        if (Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu)
        {
            return ContextCompat.CheckSelfPermission(this, Manifest.Permission.ReadMediaImages!) == Permission.Granted
                   && ContextCompat.CheckSelfPermission(this, Manifest.Permission.ReadMediaVideo!) == Permission.Granted;
        }

        return ContextCompat.CheckSelfPermission(this, Manifest.Permission.ReadExternalStorage!) == Permission.Granted;
    }

    private void TryStartSession()
    {
        if (HasMediaReadPermission())
        {
            LoadSession();
            return;
        }

        if (Build.VERSION.SdkInt >= BuildVersionCodes.Tiramisu)
        {
            RequestPermissions(
                new[] { Manifest.Permission.ReadMediaImages!, Manifest.Permission.ReadMediaVideo! },
                PermRequestCode);
        }
        else
        {
            RequestPermissions(new[] { Manifest.Permission.ReadExternalStorage! }, PermRequestCode);
        }
    }

    public override void OnRequestPermissionsResult(int requestCode, string[] permissions, Permission[] grantResults)
    {
        base.OnRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode != PermRequestCode)
        {
            return;
        }

        _permissionRequestedOnce = true;
        UpdatePermissionBanner();
        if (HasMediaReadPermission())
        {
            LoadSession();
        }
    }

    private void LoadSession()
    {
        _loadingBar!.Visibility = ViewStates.Visible;
        Task.Run(() =>
        {
            var items = _repo!.LoadRecentMedia();
            RunOnUiThread(() =>
            {
                _loadingBar.Visibility = ViewStates.Gone;
                _queue.Clear();
                _queue.AddRange(items);
                _pendingDeleteIds.Clear();
                _index = 0;
                if (_queue.Count == 0)
                {
                    Toast.MakeText(this, GetString(Resource.String.empty_gallery), ToastLength.Long)?.Show();
                    ShowMenu();
                    return;
                }

                ShowSessionUi();
                BindCurrentCard();
            });
        });
    }

    private void ShowMenu()
    {
        _menuScroll!.Visibility = ViewStates.Visible;
        _sessionLayout!.Visibility = ViewStates.Gone;
        _queue.Clear();
        _pendingDeleteIds.Clear();
        _index = 0;
        UpdatePermissionBanner();
    }

    private void ShowSessionUi()
    {
        _menuScroll!.Visibility = ViewStates.Gone;
        _sessionLayout!.Visibility = ViewStates.Visible;
        UpdateHud();
    }

    private void BindCurrentCard()
    {
        HideBadges();
        _cardImage!.TranslationX = 0f;
        if (_index >= _queue.Count)
        {
            ShowFinishDialog();
            return;
        }

        _loadingBar!.Visibility = ViewStates.Visible;
        var item = _queue[_index];
        Task.Run(() =>
        {
            Bitmap? bmp = _repo!.LoadThumbnail(item);
            RunOnUiThread(() =>
            {
                _loadingBar.Visibility = ViewStates.Gone;
                if (bmp != null)
                {
                    _cardImage.SetImageBitmap(bmp);
                }
                else
                {
                    _cardImage.SetImageResource(Android.Resource.Color.Transparent);
                }
            });
        });
        UpdateHud();
    }

    private void UpdateHud()
    {
        int remaining = Math.Max(0, _queue.Count - _index);
        _markedText!.Text = GetString(Resource.String.marked_delete, _pendingDeleteIds.Count);
        _remainingText!.Text = GetString(Resource.String.remaining, remaining);
    }

    private void HandleSwipeLeft()
    {
        if (_index >= _queue.Count)
        {
            return;
        }

        _pendingDeleteIds.Add(_queue[_index].Id);
        _index++;
        BindCurrentCard();
    }

    private void HandleSwipeRight()
    {
        if (_index >= _queue.Count)
        {
            return;
        }

        _index++;
        BindCurrentCard();
    }

    private void UpdateBadges(float dx)
    {
        if (_deleteBadge == null || _keepBadge == null)
        {
            return;
        }

        _deleteBadge.Visibility = dx < -40f ? ViewStates.Visible : ViewStates.Gone;
        _keepBadge.Visibility = dx > 40f ? ViewStates.Visible : ViewStates.Gone;
    }

    private void HideBadges()
    {
        if (_deleteBadge != null)
        {
            _deleteBadge.Visibility = ViewStates.Gone;
        }

        if (_keepBadge != null)
        {
            _keepBadge.Visibility = ViewStates.Gone;
        }
    }

    private void ShowFinishDialog()
    {
        int pending = _pendingDeleteIds.Count;
        string title = pending > 0
            ? GetString(Resource.String.delete_confirm_title, pending)
            : GetString(Resource.String.end_session_title);
        string message = pending > 0
            ? GetString(Resource.String.delete_confirm_message)
            : GetString(Resource.String.end_session_message);

        var builder = new AlertDialog.Builder(this)!
            .SetTitle(title)!
            .SetMessage(message)!;

        if (pending > 0)
        {
            builder.SetPositiveButton(GetString(Resource.String.delete_action, pending), (_, _) => ApplyDeletes());
        }
        else
        {
            builder.SetPositiveButton(GetString(Resource.String.back_to_menu), (_, _) => ShowMenu());
        }

        builder.SetNegativeButton(GetString(Resource.String.cancel), (_, _) =>
        {
            if (_index >= _queue.Count && _queue.Count > 0)
            {
                _index = _queue.Count - 1;
                BindCurrentCard();
            }
        })!.Show();
    }

    private void ApplyDeletes()
    {
        var toDelete = _queue.Where(x => _pendingDeleteIds.Contains(x.Id)).ToList();
        if (toDelete.Count == 0)
        {
            ShowMenu();
            return;
        }

        _lastDeleteCount = toDelete.Count;

        if (Build.VERSION.SdkInt >= BuildVersionCodes.R)
        {
            try
            {
                IList<Uri> uris = toDelete.Select(x => x.ContentUri).ToList();
                var pending = MediaStore.CreateDeleteRequest(ContentResolver!, uris);
                StartIntentSenderForResult(pending!.IntentSender!, DeleteRequestCode, null, 0, 0, 0, null!);
            }
            catch (Exception ex)
            {
                new AlertDialog.Builder(this)!
                    .SetTitle(Resource.String.result_title)!
                    .SetMessage(GetString(Resource.String.delete_failed, ex.Message))!
                    .SetPositiveButton(Android.Resource.String.Ok, (_, _) => ShowMenu())!
                    .Show();
            }
        }
        else
        {
            int deleted = 0;
            foreach (var item in toDelete)
            {
                try
                {
                    int rows = ContentResolver!.Delete(item.ContentUri, null, null);
                    if (rows > 0)
                    {
                        deleted++;
                    }
                }
                catch
                {
                    // ignore single failure
                }
            }

            new AlertDialog.Builder(this)!
                .SetTitle(Resource.String.result_title)!
                .SetMessage(GetString(Resource.String.deleted_count, deleted))!
                .SetPositiveButton(Android.Resource.String.Ok, (_, _) => ShowMenu())!
                .Show();
        }
    }

    protected override void OnActivityResult(int requestCode, Result resultCode, Intent? data)
    {
        base.OnActivityResult(requestCode, resultCode, data);
        if (requestCode != DeleteRequestCode)
        {
            return;
        }

        string msg = resultCode == Result.Ok
            ? GetString(Resource.String.deleted_count, _lastDeleteCount)
            : GetString(Resource.String.delete_failed, "cancelled");

        new AlertDialog.Builder(this)!
            .SetTitle(Resource.String.result_title)!
            .SetMessage(msg)!
            .SetPositiveButton(Android.Resource.String.Ok, (_, _) => ShowMenu())!
            .Show();
    }

    private sealed class SwipeTouchListener : Java.Lang.Object, View.IOnTouchListener
    {
        private readonly Action _onSwipeLeft;
        private readonly Action _onSwipeRight;
        private readonly Action<float> _onDrag;
        private readonly Action _onCancelDrag;
        private float _downX;

        public SwipeTouchListener(Action onSwipeLeft, Action onSwipeRight, Action<float> onDrag, Action onCancelDrag)
        {
            _onSwipeLeft = onSwipeLeft;
            _onSwipeRight = onSwipeRight;
            _onDrag = onDrag;
            _onCancelDrag = onCancelDrag;
        }

        public bool OnTouch(View? v, MotionEvent? e)
        {
            if (v == null || e == null)
            {
                return false;
            }

            switch (e.ActionMasked)
            {
                case MotionEventActions.Down:
                    _downX = e.RawX;
                    return true;
                case MotionEventActions.Move:
                    float dx = e.RawX - _downX;
                    v.TranslationX = dx;
                    _onDrag(dx);
                    return true;
                case MotionEventActions.Up:
                case MotionEventActions.Cancel:
                    float total = e.RawX - _downX;
                    if (total < -SwipeThresholdPx)
                    {
                        _onSwipeLeft();
                    }
                    else if (total > SwipeThresholdPx)
                    {
                        _onSwipeRight();
                    }
                    else
                    {
                        v.Animate()?.TranslationX(0)?.SetDuration(150)?.Start();
                        _onCancelDrag();
                    }

                    return true;
                default:
                    return false;
            }
        }
    }
}
