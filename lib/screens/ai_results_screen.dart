import 'package:flutter/material.dart';

class AIResultsScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const AIResultsScreen({Key? key, required this.analysisData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Analysis Results'),
        backgroundColor: Color(0xFF002B5B),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002B5B), Color(0xFF00509D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            'Your analysis results will appear here',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}