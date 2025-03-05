// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class Tracking extends StatefulWidget {
  const Tracking({Key? key}) : super(key: key);

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(240, 240, 235, 1.0),
      body: SafeArea(
        child: content(),
      ),
    );
  }

  Widget content() {
    return PlaceholderContent();
  }

  Widget PlaceholderContent() {
    return Column(
      children: <Widget>[
        SizedBox(height: 5.0),
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              'Mood Tracking',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Center(
            child: Text(
              'No data available. Please check back later.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                // Placeholder action
              },
              child: Text('Refresh'),
            ),
          ),
        ),
      ],
    );
  }
}
