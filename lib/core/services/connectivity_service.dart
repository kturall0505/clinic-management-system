import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus { online, offline, unknown }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  final StreamController<ConnectionStatus> _controller = StreamController<ConnectionStatus>.broadcast();

  Stream<ConnectionStatus> get connectionStream => _controller.stream;
  ConnectionStatus _currentStatus = ConnectionStatus.unknown;

  ConnectionStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    await checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.ethernet)) {
        _currentStatus = ConnectionStatus.online;
      } else if (result.contains(ConnectivityResult.none)) {
        _currentStatus = ConnectionStatus.offline;
      } else {
        _currentStatus = ConnectionStatus.unknown;
      }
      _controller.add(_currentStatus);
    });
  }

  Future<ConnectionStatus> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.ethernet)) {
        _currentStatus = ConnectionStatus.online;
      } else if (result.contains(ConnectivityResult.none)) {
        _currentStatus = ConnectionStatus.offline;
      } else {
        _currentStatus = ConnectionStatus.unknown;
      }
      _controller.add(_currentStatus);
      return _currentStatus;
    } catch (e) {
      _currentStatus = ConnectionStatus.unknown;
      _controller.add(_currentStatus);
      return ConnectionStatus.unknown;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
