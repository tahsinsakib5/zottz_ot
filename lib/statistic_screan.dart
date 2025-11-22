// screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:zottz_ot/firebase_data_model.dart';
import 'package:zottz_ot/firebase_service.dart';
// import '../services/firebase_service.dart';
// import '../models/user_information.dart';

class StatisticsScreen extends StatefulWidget {
  final String userName;

  const StatisticsScreen({Key? key, required this.userName}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Statistics')),
      body: StreamBuilder<List<UserInformation>>(
        stream: _firebaseService.getUserInformationStream(widget.userName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userInfoList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: userInfoList.length,
            itemBuilder: (context, index) {
              final info = userInfoList[index];
              return Card(
                child: ListTile(
                  title: Text('Name: ${info.userName}    Age: ${info.userAge}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scissor: ${info.scissor}  Pincher: ${info.pincher}'),
                      Text('Pencil: ${info.pencil}  Button: ${info.button}'),
                      Text('Date: ${info.sessionDate}  Timer: ${info.timer}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportData,
        child: Icon(Icons.share),
      ),
    );
  }

  void _exportData() {
    // Implement CSV export functionality
    // This would use the csv package to generate and share data
  }
}