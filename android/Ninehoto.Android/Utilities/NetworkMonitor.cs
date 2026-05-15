using System;
using Android.Net;
using Android.Content;

namespace Ninehoto.Android.Utilities
{
    public class NetworkMonitor
    {
        private static NetworkMonitor? _instance;
        public static NetworkMonitor Instance => _instance ??= new NetworkMonitor();

        private ConnectivityManager? _connectivityManager;
        private NetworkCallback? _networkCallback;
        private bool _isConnected;
        private ConnectionType _connectionType;

        public bool IsConnected => _isConnected;
        public ConnectionType ConnectionType => _connectionType;

        public enum ConnectionType
        {
            WiFi,
            Cellular,
            Ethernet,
            None,
            Unknown
        }

        private NetworkMonitor()
        {
            _connectivityManager = Application.Context.GetSystemService(Context.ConnectivityService) as ConnectivityManager;
        }

        public void StartMonitoring()
        {
            if (_connectivityManager == null)
                return;

            var networkRequest = new NetworkRequest.Builder()
                .AddCapability(NetCapability.Internet)
                .Build();

            _networkCallback = new NetworkCallback(
                onAvailable: (network) =>
                {
                    _isConnected = true;
                    UpdateConnectionType();
                    var loggingService = new LoggingService();
                    loggingService.Info($"Network: Connected via {_connectionType}");
                },
                onLost: (network) =>
                {
                    _isConnected = false;
                    _connectionType = ConnectionType.None;
                    var loggingService = new LoggingService();
                    loggingService.Warning("Network: Disconnected");
                }
            );

            _connectivityManager.RegisterNetworkCallback(networkRequest, _networkCallback);
            UpdateConnectionType();
        }

        public void StopMonitoring()
        {
            if (_connectivityManager != null && _networkCallback != null)
            {
                try
                {
                    _connectivityManager.UnregisterNetworkCallback(_networkCallback);
                }
                catch { }
            }
        }

        private void UpdateConnectionType()
        {
            if (_connectivityManager == null)
            {
                _connectionType = ConnectionType.Unknown;
                return;
            }

            var activeNetwork = _connectivityManager.ActiveNetwork;
            if (activeNetwork == null)
            {
                _connectionType = ConnectionType.None;
                return;
            }

            var capabilities = _connectivityManager.GetNetworkCapabilities(activeNetwork);
            if (capabilities == null)
            {
                _connectionType = ConnectionType.Unknown;
                return;
            }

            if (capabilities.HasTransport(Transport.Wifi))
            {
                _connectionType = ConnectionType.WiFi;
            }
            else if (capabilities.HasTransport(Transport.Cellular))
            {
                _connectionType = ConnectionType.Cellular;
            }
            else if (capabilities.HasTransport(Transport.Ethernet))
            {
                _connectionType = ConnectionType.Ethernet;
            }
            else
            {
                _connectionType = ConnectionType.Unknown;
            }
        }

        public bool IsOnWiFi => _connectionType == ConnectionType.WiFi;
        public bool IsOnCellular => _connectionType == ConnectionType.Cellular;

        private class NetworkCallback : ConnectivityManager.NetworkCallback
        {
            public Action<Network>? onAvailable { get; set; }
            public Action<Network>? onLost { get; set; }

            public NetworkCallback(Action<Network>? onAvailable = null, Action<Network>? onLost = null)
            {
                this.onAvailable = onAvailable;
                this.onLost = onLost;
            }

            public override void OnAvailable(Network network)
            {
                onAvailable?.Invoke(network);
            }

            public override void OnLost(Network network)
            {
                onLost?.Invoke(network);
            }
        }
    }
}