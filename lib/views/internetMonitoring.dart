import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'internetChecker.dart';

class InternetAwareWidget extends StatefulWidget {
  final Widget child;

  const InternetAwareWidget({super.key, required this.child});

  @override
  State<InternetAwareWidget> createState() => _InternetAwareWidgetState();
}

class _InternetAwareWidgetState extends State<InternetAwareWidget> {
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    Connectivity().onConnectivityChanged.listen((status) {
      _checkConnection();
    });
  }

  void _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _hasConnection = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _hasConnection ? widget.child : const NoInternetScreen();
  }
}
