import 'package:signalr_netcore/signalr_client.dart';

class PassengerSignalRService {
  HubConnection? _hubConnection;
  Function(String passengerId, double latitude, double longitude)? onLocationUpdate;
  
  Future<void> connect({required String passengerId}) async {
    final hubUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/passengerHub';
    
    print('[SignalR] Creating PassengerHub connection...');
    print('[SignalR] Hub URL: $hubUrl');
    
    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();

    // Set up event handlers
    _hubConnection?.on('PassengerLocationUpdated', (args) {
      print('[SignalR] PassengerLocationUpdated received: $args');
      if (args != null && args.length == 3) {
        final id = args[0]?.toString() ?? '';
        final lat = double.tryParse(args[1]?.toString() ?? '');
        final lng = double.tryParse(args[2]?.toString() ?? '');
        
        print('[SignalR] Parsed - ID: $id, Lat: $lat, Lng: $lng');
        
        if (id == passengerId && lat != null && lng != null) {
          print('[SignalR] Calling location update callback');
          onLocationUpdate?.call(id, lat, lng);
        }
      }
    });

    // Connection state handlers
    _hubConnection?.onclose(({error}) {
      print('[SignalR] PassengerHub Connection closed');
      if (error != null) {
        print('[SignalR] Close error: $error');
      }
    });

    _hubConnection?.onreconnecting(({error}) {
      print('[SignalR] PassengerHub Reconnecting...');
      if (error != null) {
        print('[SignalR] Reconnecting due to: $error');
      }
    });

    _hubConnection?.onreconnected(({connectionId}) {
      print('[SignalR] PassengerHub Reconnected! Connection ID: $connectionId');
    });

    // Start connection
    try {
      print('[SignalR] Starting PassengerHub connection...');
      await _hubConnection?.start();
      print('[SignalR] PassengerHub Connected successfully!');
      print('[SignalR] Connection State: ${_hubConnection?.state}');
      print('[SignalR] Connection ID: ${_hubConnection?.connectionId}');
    } catch (e) {
      print('[SignalR] PassengerHub Connection Error: $e');
      print('[SignalR] Error details: ${e.toString()}');
      rethrow;
    }
  }

  void disconnect() {
    print('[SignalR] Disconnecting PassengerHub...');
    _hubConnection?.stop();
  }

  bool get isConnected => _hubConnection?.state?.toString().contains('Connected') ?? false;
}

class BusSignalRService {
  HubConnection? _hubConnection;
  Function(String busId, double latitude, double longitude)? onBusLocationUpdate;
  Function(String busId)? onBusLocationRemove;
  int _retryCount = 0;
  static const int maxRetries = 5;
  bool _isManualDisconnect = false;

  Future<void> connect() async {
    if (_retryCount >= maxRetries) {
      print('[SignalR] Max retries ($maxRetries) reached for BusHub');
      return;
    }

    _isManualDisconnect = false;
    final hubUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/busHub';
    
    print('[SignalR] Creating BusHub connection (attempt ${_retryCount + 1}/$maxRetries)...');
    print('[SignalR] Hub URL: $hubUrl');

    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl)
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _hubConnection?.on('BusLocationUpdated', (args) {
        print('[SignalR] BusLocationUpdated received: $args');
        if (args != null && args.length == 3) {
          final id = args[0]?.toString() ?? '';
          final lat = double.tryParse(args[1]?.toString() ?? '');
          final lng = double.tryParse(args[2]?.toString() ?? '');
          
          print('[SignalR] Parsed Bus - ID: $id, Lat: $lat, Lng: $lng');
          
          if (lat != null && lng != null) {
            onBusLocationUpdate?.call(id, lat, lng);
          }
        }
      });

      _hubConnection?.on('RemoveBusLocation', (args) {
        print('[SignalR] RemoveBusLocation received: $args');
        if (args != null && args.length == 1) {
          final id = args[0]?.toString() ?? '';
          if (id.isNotEmpty) {
            print('[SignalR] Removing bus: $id');
            onBusLocationRemove?.call(id);
          }
        }
      });

      _hubConnection?.onclose(({error}) {
        print('[SignalR] BusHub Connection closed');
        if (error != null) {
          print('[SignalR] Close error: $error');
          print('[SignalR] Error type: ${error.runtimeType}');
        }
        
        if (!_isManualDisconnect) {
          print('[SignalR] Connection lost, attempting retry...');
          _retryConnection();
        }
      });

      _hubConnection?.onreconnecting(({error}) {
        print('[SignalR] BusHub Reconnecting...');
        if (error != null) {
          print('[SignalR] Reconnecting due to: $error');
        }
      });

      _hubConnection?.onreconnected(({connectionId}) {
        print('[SignalR] BusHub Reconnected! Connection ID: $connectionId');
        _retryCount = 0; // Reset on successful reconnection
      });

      print('[SignalR] Starting BusHub connection...');
      await _hubConnection?.start();
      
      print('[SignalR] BusHub Connected successfully!');
      print('[SignalR] Connection State: ${_hubConnection?.state}');
      print('[SignalR] Connection ID: ${_hubConnection?.connectionId}');
      
      _retryCount = 0; // Reset on successful connection
      
    } catch (e) {
      print('[SignalR] BusHub Connection Error: $e');
      print('[SignalR] Error type: ${e.runtimeType}');
      print('[SignalR] Current state: ${_hubConnection?.state}');
      
      if (!_isManualDisconnect) {
        await _retryConnection();
      }
    }
  }

  Future<void> _retryConnection() async {
    _retryCount++;
    
    if (_retryCount < maxRetries && !_isManualDisconnect) {
      final delay = _retryCount * 2; // Exponential backoff: 2, 4, 6, 8 seconds
      print('[SignalR] Retrying BusHub connection in ${delay}s... (attempt $_retryCount/$maxRetries)');
      
      await Future.delayed(Duration(seconds: delay));
      await connect();
    } else {
      print('[SignalR] Failed to connect to BusHub after $maxRetries attempts');
    }
  }

  void disconnect() {
    print('[SignalR] Manually disconnecting BusHub...');
    _isManualDisconnect = true;
    _retryCount = maxRetries; // Prevent retries
    _hubConnection?.stop();
  }

  bool get isConnected => _hubConnection?.state?.toString().contains('Connected') ?? false;
  String? get connectionState => _hubConnection?.state?.toString();
}

class NotificationSignalRService {
  static final NotificationSignalRService instance = NotificationSignalRService._internal();
  NotificationSignalRService._internal();
  factory NotificationSignalRService() => instance;
  HubConnection? _hubConnection;
  final List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  final List<void Function(Map<String, dynamic>)> _listeners = [];
  final List<void Function(int)> _unreadListeners = [];

  String? _currentTripBusNumberPlate;
  String? _passengerId;

  List<Map<String, dynamic>> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  void setCurrentTripBusNumberPlate(String? busNumberPlate) {
    print('[NotificationSignalRService] setCurrentTripBusNumberPlate: $busNumberPlate');
    _currentTripBusNumberPlate = busNumberPlate;
  }

  void setPassengerId(String? passengerId) {
    print('[NotificationSignalRService] setPassengerId: $passengerId');
    _passengerId = passengerId;
  }

  Future<void> connect({required String passengerId}) async {
    final hubUrl = 'https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/notificationHub';
    print('[NotificationSignalRService] Creating NotificationHub connection...');
    print('[NotificationSignalRService] Hub URL: $hubUrl');

    _passengerId = passengerId;

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl)
        .withAutomaticReconnect()
        .build();

    // BusFull event
    _hubConnection?.on('BusFull', (args) {
      print('[NotificationSignalRService] [RECEIVE] BusFull event args: $args');
      if (args != null && args.isNotEmpty) {
        final numberPlate = args[0]?.toString() ?? '';
        print('[NotificationSignalRService] BusFull numberPlate: $numberPlate, currentTrip: $_currentTripBusNumberPlate');
        if (_currentTripBusNumberPlate != null && numberPlate == _currentTripBusNumberPlate) {
          final notification = <String, dynamic>{
            'title': 'Bus Full',
            'message': 'Bus $numberPlate is now full.',
            'timestamp': DateTime.now().toIso8601String(),
            'type': 'bus',
          };
          _addNotification(notification);
        } else {
          print('[NotificationSignalRService] [FILTERED] BusFull event ignored: not current trip bus.');
        }
      }
    });

    // BusSOS event
    _hubConnection?.on('BusSOS', (args) {
      print('[NotificationSignalRService] [RECEIVE] BusSOS event args: $args');
      if (args != null && args.isNotEmpty) {
        final numberPlate = args[0]?.toString() ?? '';
        print('[NotificationSignalRService] BusSOS numberPlate: $numberPlate, currentTrip: $_currentTripBusNumberPlate');
        if (_currentTripBusNumberPlate != null && numberPlate == _currentTripBusNumberPlate) {
          final notification = <String, dynamic>{
            'title': 'Bus SOS',
            'message': 'SOS! Bus $numberPlate has sent an SOS signal.',
            'timestamp': DateTime.now().toIso8601String(),
            'type': 'bus',
          };
          _addNotification(notification);
        } else {
          print('[NotificationSignalRService] [FILTERED] BusSOS event ignored: not current trip bus.');
        }
      }
    });

    // FeedbackReplied event
    _hubConnection?.on('FeedbackReplied', (args) {
      print('[NotificationSignalRService] [RECEIVE] FeedbackReplied event args: $args');
      if (args != null && args.isNotEmpty) {
        String feedbackPassengerId = '';
        String subject = '';
        if (args.length >= 2) {
          // Old format: [Map, subject]
          final feedback = args[0];
          subject = args[1]?.toString() ?? '';
          if (feedback is Map && feedback['PassengerId'] != null) {
            feedbackPassengerId = feedback['PassengerId'].toString();
          }
        } else if (args.length == 1 && args[0] is String) {
          // New format: [String]
          final msg = args[0] as String;
          // Try to extract passenger ID and subject from the string
          final match = RegExp(r'Feedback from Passenger (\w+) has been replied: (.+)').firstMatch(msg);
          if (match != null) {
            feedbackPassengerId = match.group(1) ?? '';
            subject = match.group(2) ?? '';
          }
        }
        print('[NotificationSignalRService] FeedbackReplied feedbackPassengerId: $feedbackPassengerId, myPassengerId: $_passengerId');
        if (_passengerId != null && feedbackPassengerId == _passengerId) {
          final notification = <String, dynamic>{
            'title': 'Feedback Replied',
            'message': 'Feedback from Passenger $feedbackPassengerId has been replied: $subject',
            'timestamp': DateTime.now().toIso8601String(),
            'type': 'feedback',
          };
          _addNotification(notification);
        } else {
          print('[NotificationSignalRService] [FILTERED] FeedbackReplied event ignored: not for this passenger.');
        }
      }
    });

    // Optionally, keep ReceiveNotification for generic notifications
    _hubConnection?.on('ReceiveNotification', (args) {
      print('[NotificationSignalRService] [RECEIVE] ReceiveNotification event args: $args');
      if (args != null && args.isNotEmpty) {
        final notification = <String, dynamic>{
          'title': args[0]?.toString() ?? '',
          'message': args.length > 1 ? args[1]?.toString() ?? '' : '',
          'timestamp': DateTime.now().toIso8601String(),
          'type': 'generic',
        };
        _addNotification(notification);
      }
    });

    _hubConnection?.onclose(({error}) {
      print('[NotificationSignalRService] NotificationHub Connection closed');
      if (error != null) {
        print('[NotificationSignalRService] Close error: $error');
      }
    });

    _hubConnection?.onreconnecting(({error}) {
      print('[NotificationSignalRService] NotificationHub Reconnecting...');
      if (error != null) {
        print('[NotificationSignalRService] Reconnecting due to: $error');
      }
    });

    _hubConnection?.onreconnected(({connectionId}) {
      print('[NotificationSignalRService] NotificationHub Reconnected! Connection ID: $connectionId');
    });

    // Start connection
    try {
      print('[NotificationSignalRService] Starting NotificationHub connection...');
      await _hubConnection?.start();
      print('[NotificationSignalRService] NotificationHub Connected successfully!');
      print('[NotificationSignalRService] Connection State: ${_hubConnection?.state}');
      print('[NotificationSignalRService] Connection ID: ${_hubConnection?.connectionId}');
    } catch (e) {
      print('[NotificationSignalRService] NotificationHub Connection Error: $e');
      print('[NotificationSignalRService] Error details: ${e.toString()}');
      rethrow;
    }
  }

  void _addNotification(Map<String, dynamic> notification) {
    print('[NotificationSignalRService] Adding notification: $notification');
    _notifications.insert(0, notification);
    _unreadCount++;
    for (final listener in _listeners) {
      print('[NotificationSignalRService] Notifying listener of new notification');
      listener(notification);
    }
    for (final listener in _unreadListeners) {
      print('[NotificationSignalRService] Notifying unread count listener: count = $_unreadCount');
      listener(_unreadCount);
    }
  }

  void removeNotification(Map<String, dynamic> notification) {
    print('[NotificationSignalRService] Removing notification: $notification');
    _notifications.remove(notification);
  }

  void disconnect() {
    print('[NotificationSignalRService] Disconnecting NotificationHub...');
    _hubConnection?.stop();
  }

  void markAllAsRead() {
    print('[NotificationSignalRService] Marking all notifications as read');
    _unreadCount = 0;
    for (final listener in _unreadListeners) {
      print('[NotificationSignalRService] Notifying unread count listener: count = $_unreadCount');
      listener(_unreadCount);
    }
  }

  void addNotificationListener(void Function(Map<String, dynamic>) listener) {
    print('[NotificationSignalRService] Adding notification listener');
    _listeners.add(listener);
  }

  void removeNotificationListener(void Function(Map<String, dynamic>) listener) {
    print('[NotificationSignalRService] Removing notification listener');
    _listeners.remove(listener);
  }

  void addUnreadListener(void Function(int) listener) {
    print('[NotificationSignalRService] Adding unread count listener');
    _unreadListeners.add(listener);
  }

  void removeUnreadListener(void Function(int) listener) {
    print('[NotificationSignalRService] Removing unread count listener');
    _unreadListeners.remove(listener);
  }
}

// Test function to check server connectivity
Future<void> testServerConnectivity() async {
  print('[Test] Testing server connectivity...');
  
  try {
    // You can use http package to test if server is reachable
    // import 'package:http/http.dart' as http;
    // final response = await http.get(Uri.parse('https://bus-finder-sl-a7c6a549fbb1.herokuapp.com'));
    // print('[Test] Server response status: ${response.statusCode}');
    
    print('[Test] Please manually check these URLs in browser:');
    print('- https://bus-finder-sl-a7c6a549fbb1.herokuapp.com');
    print('- https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/busHub');
    print('- https://bus-finder-sl-a7c6a549fbb1.herokuapp.com/passengerHub');
    
  } catch (e) {
    print('[Test] Server connectivity test failed: $e');
  }
}