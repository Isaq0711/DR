import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const GeolocatorWidget());
}

class GeolocatorWidget extends StatefulWidget {
  const GeolocatorWidget({Key? key}) : super(key: key);

  @override
  State<GeolocatorWidget> createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<String> _positionItems = [];
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;

  @override
  void initState() {
    super.initState();
    _toggleServiceStatusStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geolocator Example'),
        actions: [
          _createActions(),
        ],
      ),
      body: ListView.builder(
        itemCount: _positionItems.length,
        itemBuilder: (context, index) {
          final positionItem = _positionItems[index];
          return ListTile(
            title: Text(positionItem),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          positionStreamStarted = !positionStreamStarted;
          _toggleListening();
        },
        tooltip: (_positionStreamSubscription == null)
            ? 'Start position updates'
            : _positionStreamSubscription!.isPaused
                ? 'Resume'
                : 'Pause',
        child: (_positionStreamSubscription == null ||
                _positionStreamSubscription!.isPaused)
            ? const Icon(Icons.play_arrow)
            : const Icon(Icons.pause),
      ),
    );
  }

  PopupMenuButton _createActions() {
    return PopupMenuButton(
      onSelected: (value) async {
        switch (value) {
          case 1:
            _getLocationAccuracy();
            break;
          case 2:
            _requestTemporaryFullAccuracy();
            break;
          case 3:
            _openAppSettings();
            break;
          case 4:
            _openLocationSettings();
            break;
          case 5:
            setState(() {
              _positionItems.clear();
            });
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) => [
        if (Platform.isIOS)
          const PopupMenuItem(
            value: 1,
            child: Text("Get Location Accuracy"),
          ),
        if (Platform.isIOS)
          const PopupMenuItem(
            value: 2,
            child: Text("Request Temporary Full Accuracy"),
          ),
        const PopupMenuItem(
          value: 3,
          child: Text("Open App Settings"),
        ),
        if (Platform.isAndroid || Platform.isWindows)
          const PopupMenuItem(
            value: 4,
            child: Text("Open Location Settings"),
          ),
        const PopupMenuItem(
          value: 5,
          child: Text("Clear"),
        ),
      ],
    );
  }

  Future<void> _getLocationAccuracy() async {
    final status = await _geolocatorPlatform.getLocationAccuracy();
    _handleLocationAccuracyStatus(status);
  }

  Future<void> _requestTemporaryFullAccuracy() async {
    final status = await _geolocatorPlatform.requestTemporaryFullAccuracy(
      purposeKey: "TemporaryPreciseAccuracy",
    );
    _handleLocationAccuracyStatus(status);
  }

  void _handleLocationAccuracyStatus(LocationAccuracyStatus status) {
    String locationAccuracyStatusValue;
    if (status == LocationAccuracyStatus.precise) {
      locationAccuracyStatusValue = 'Precise';
    } else if (status == LocationAccuracyStatus.reduced) {
      locationAccuracyStatusValue = 'Reduced';
    } else {
      locationAccuracyStatusValue = 'Unknown';
    }
    _updatePositionList(
        '$locationAccuracyStatusValue location accuracy granted.');
  }

  void _updatePositionList(String displayValue) {
    _positionItems.add(displayValue);
    setState(() {});
  }

  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;
        if (serviceStatus == ServiceStatus.enabled) {
          if (positionStreamStarted) {
            _toggleListening();
          }
          serviceStatusValue = 'enabled';
        } else {
          if (_positionStreamSubscription != null) {
            setState(() {
              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;
              _updatePositionList('Position Stream has been canceled');
            });
          }
          serviceStatusValue = 'disabled';
        }
        _updatePositionList('Location service has been $serviceStatusValue');
      });
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) {
        _updatePositionList(position.toString());
      });
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }

      _updatePositionList('Listening for position updates $statusDisplayValue');
    });
  }

  void _openAppSettings() async {
    final opened = await _geolocatorPlatform.openAppSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Application Settings.';
    } else {
      displayValue = 'Error opening Application Settings.';
    }

    _updatePositionList(displayValue);
  }

  void _openLocationSettings() async {
    final opened = await _geolocatorPlatform.openLocationSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Location Settings';
    } else {
      displayValue = 'Error opening Location Settings';
    }

    _updatePositionList(displayValue);
  }
}
