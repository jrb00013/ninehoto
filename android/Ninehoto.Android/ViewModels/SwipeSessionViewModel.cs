using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading.Tasks;
using Android.App;
using Android.Hardware;
using Ninehoto.Android.Interfaces;
using Ninehoto.Android.Models;
using Ninehoto.Android.Services;

namespace Ninehoto.Android.ViewModels
{
    public enum AppPhase
    {
        MainMenu,
        Swiping
    }

    public class SwipeSessionViewModel : ViewModelBase
    {
        private const int SessionLimit = 200;

        private readonly IMediaService _mediaService;
        private readonly IPreferencesService _preferencesService;
        private readonly ILoggingService _logger;

        private AppPhase _phase = AppPhase.MainMenu;
        private Android.Provider.MediaStoreStatus _authorizationState;
        private ObservableCollection<MediaItem> _assets = new();
        private int _currentIndex;
        private HashSet<string> _pendingDeletionIds = new();
        private bool _showFinishConfirmation;
        private bool _showResultAlert;
        private string _resultMessage = "";
        private bool _isLoading;
        private bool _canUndo;
        private DateTime _sessionStartTime;

        public AppPhase Phase
        {
            get => _phase;
            set => SetProperty(ref _phase, value);
        }

        public Android.Provider.MediaStoreStatus AuthorizationState
        {
            get => _authorizationState;
            set => SetProperty(ref _authorizationState, value);
        }

        public ObservableCollection<MediaItem> Assets
        {
            get => _assets;
            set => SetProperty(ref _assets, value);
        }

        public int CurrentIndex
        {
            get => _currentIndex;
            set => SetProperty(ref _currentIndex, value);
        }

        public bool ShowFinishConfirmation
        {
            get => _showFinishConfirmation;
            set => SetProperty(ref _showFinishConfirmation, value);
        }

        public bool ShowResultAlert
        {
            get => _showResultAlert;
            set => SetProperty(ref _showResultAlert, value);
        }

        public string ResultMessage
        {
            get => _resultMessage;
            set => SetProperty(ref _resultMessage, value);
        }

        public bool IsLoading
        {
            get => _isLoading;
            set => SetProperty(ref _isLoading, value);
        }

        public bool CanUndo
        {
            get => _canUndo;
            set => SetProperty(ref _canUndo, value);
        }

        public bool CanStartSession => AuthorizationState != Android.Provider.MediaStoreStatus.Denied && 
                                       AuthorizationState != Android.Provider.MediaStoreStatus.Restricted;

        public MediaItem? CurrentAsset => CurrentIndex >= 0 && CurrentIndex < Assets.Count 
            ? Assets[CurrentIndex] : null;

        public int RemainingCount => Math.Max(0, Assets.Count - CurrentIndex);
        public int PendingDeleteCount => _pendingDeletionIds.Count;

        private Stack<(int index, string id)> _undoStack = new();

        public SwipeSessionViewModel(IMediaService mediaService, IPreferencesService preferencesService, ILoggingService logger)
        {
            _mediaService = mediaService;
            _preferencesService = preferencesService;
            _logger = logger;
        }

        public void RefreshAuthorization()
        {
            AuthorizationState = _mediaService.RequestPermissionAsync().Result;
        }

        public async Task RequestAccessAsync()
        {
            var status = await _mediaService.RequestPermissionAsync();
            AuthorizationState = status;
        }

        public async Task StartSessionAsync()
        {
            if (AuthorizationState == Android.Provider.MediaStoreStatus.NotDetermined)
            {
                await RequestAccessAsync();
            }

            if (!CanStartSession) return;

            IsLoading = true;
            _logger.Info("Starting swipe session");

            try
            {
                var fetched = await _mediaService.FetchRecentMediaAsync(SessionLimit);

                if (fetched.Count == 0)
                {
                    ResultMessage = "No photos or videos were found in your library.";
                    ShowResultAlert = true;
                    Phase = AppPhase.MainMenu;
                    return;
                }

                Assets = new ObservableCollection<MediaItem>(fetched);
                CurrentIndex = 0;
                _pendingDeletionIds = new HashSet<string>();
                _undoStack = new Stack<(int, string)>();
                CanUndo = false;
                Phase = AppPhase.Swiping;
                _sessionStartTime = DateTime.Now;

                await PrefetchNextAsync();
            }
            catch (Exception ex)
            {
                _logger.Error(ex, "Failed to start session");
                ResultMessage = "Failed to load photos.";
                ShowResultAlert = true;
            }
            finally
            {
                IsLoading = false;
            }
        }

        private async Task PrefetchNextAsync()
        {
            var start = CurrentIndex;
            var end = Math.Min(start + 5, Assets.Count);
            if (end <= start) return;

            // Prefetch logic here
            await Task.CompletedTask;
        }

        public void SwipeLeft()
        {
            if (CurrentAsset == null) return;

            var id = CurrentAsset.Id;
            if (!_pendingDeletionIds.Contains(id))
            {
                _pendingDeletionIds.Add(id);
                _undoStack.Push((CurrentIndex, id));
                CanUndo = true;
                _preferencesService.SwipeCount++;
                _preferencesService.DeleteCount++;
            }

            Advance();
            _ = PrefetchNextAsync();
        }

        public void SwipeRight()
        {
            if (CurrentAsset == null) return;

            var id = CurrentAsset.Id;
            if (_pendingDeletionIds.Contains(id))
            {
                _pendingDeletionIds.Remove(id);
                _undoStack.Push((CurrentIndex, id));
                CanUndo = true;
                _preferencesService.SwipeCount++;
                _preferencesService.KeepCount++;
            }

            Advance();
            _ = PrefetchNextAsync();
        }

        public void UndoLastSwipe()
        {
            if (_undoStack.Count == 0) return;

            var last = _undoStack.Pop();
            if (CurrentIndex != last.index)
            {
                CurrentIndex = last.index;
            }

            if (_pendingDeletionIds.Contains(last.id))
            {
                _pendingDeletionIds.Remove(last.id);
            }
            else
            {
                _pendingDeletionIds.Add(last.id);
            }

            CanUndo = _undoStack.Count > 0;
        }

        private void Advance()
        {
            if (CurrentIndex + 1 < Assets.Count)
            {
                CurrentIndex++;
            }
            else
            {
                ShowFinishConfirmation = true;
            }
        }

        public void TapDone()
        {
            ShowFinishConfirmation = true;
        }

        public void CancelFinish()
        {
            ShowFinishConfirmation = false;
        }

        public async Task ConfirmFinishAndApplyDeletesAsync()
        {
            ShowFinishConfirmation = false;
            var toDelete = Assets.Where(a => _pendingDeletionIds.Contains(a.Id)).ToList();

            if (toDelete.Count == 0)
            {
                ResetToMainMenu();
                return;
            }

            try
            {
                var ids = toDelete.Select(a => a.Id).ToList();
                var success = await _mediaService.DeleteMediaAsync(ids);

                if (success)
                {
                    ResultMessage = $"Deleted {toDelete.Count} item(s).";
                    SaveSessionStatistics(toDelete.Count);
                }
                else
                {
                    ResultMessage = "Some deletes may have failed.";
                }
            }
            catch (Exception ex)
            {
                _logger.Error(ex, "Delete failed");
                ResultMessage = $"Some deletes may have failed: {ex.Message}";
            }

            ShowResultAlert = true;
            ResetToMainMenu();
        }

        private void SaveSessionStatistics(int deletedCount)
        {
            var duration = (DateTime.Now - _sessionStartTime).TotalSeconds;
            var stats = new SessionStatistics
            {
                SwipeCount = _preferencesService.SwipeCount,
                DeleteCount = deletedCount,
                KeepCount = _preferencesService.SwipeCount - deletedCount,
                SessionDate = _sessionStartTime,
                DurationSeconds = duration,
                AverageSwipesPerMinute = duration > 0 ? (_preferencesService.SwipeCount / (duration / 60)) : 0
            };

            var tracker = new StatisticsTracker(Android.App.Application.Context.GetSharedPreferences("ninehoto_prefs", Android.Content.FileCreationMode.Private));
            tracker.SaveSession(stats);
        }

        public void DismissResult()
        {
            ShowResultAlert = false;
        }

        public void ResetToMainMenu()
        {
            Phase = AppPhase.MainMenu;
            Assets = new ObservableCollection<MediaItem>();
            CurrentIndex = 0;
            _pendingDeletionIds = new HashSet<string>();
            _undoStack = new Stack<(int, string)>();
            CanUndo = false;
        }

        public void BackToMenuWithoutDeleting()
        {
            ShowFinishConfirmation = false;
            ResetToMainMenu();
        }
    }
}