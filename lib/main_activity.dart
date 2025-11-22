// screens/ot_control_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:zottz_ot/firebase_data_model.dart';
import 'package:zottz_ot/firebase_service.dart';
// import '../services/firebase_service.dart';
// import '../models/user_information.dart';
// import '../utils/date_utils.dart';

class OTControlScreen extends StatefulWidget {
  final Map<String, dynamic> settings;

  const OTControlScreen({Key? key, required this.settings}) : super(key: key);

  @override
  _OTControlScreenState createState() => _OTControlScreenState();
}

class _OTControlScreenState extends State<OTControlScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  BluetoothDevice? _device;
  BluetoothCharacteristic? _characteristic;
  
  // Counters
  int _countScissor = 0;
  int _countPincher = 0;
  int _countPencil = 0;
  int _countButton = 0;
  
  // Timer
  TimerStatus _timerStatus = TimerStatus.stopped;
  Duration _remainingTime = Duration.zero;
  Duration _selectedDuration = Duration.zero;
  bool _isPaused = false;
  
  // Settings
  late String _userName;
  late Map<String, String> _colors;
  late Map<String, String> _music;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _connectToDevice();
  }

  void _initializeData() {
    _userName = widget.settings['userName'];
    _device = widget.settings['device'];
    
    _colors = {
      'scissor': widget.settings['colorScissor'],
      'pincher': widget.settings['colorPincher'],
      'pencil': widget.settings['colorPencil'],
      'button': widget.settings['colorButton'],
    };
    
    _music = {
      'scissor': widget.settings['musicScissor'],
      'pincher': widget.settings['musicPincher'],
      'pencil': widget.settings['musicPencil'],
      'button': widget.settings['musicButton'],
    };
  }

  Future<void> _connectToDevice() async {
    if (_device != null) {
      // await _device!.connect();
      List<BluetoothService> services = await _device!.discoverServices();
      
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == "0000ffe0-0000-1000-8000-00805f9b34fb") {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == "0000ffe1-0000-1000-8000-00805f9b34fb") {
              _characteristic = characteristic;
              await characteristic.setNotifyValue(true);
              characteristic.value.listen(_handleBluetoothData);
              break;
            }
          }
        }
      }
    }
  }

  void _handleBluetoothData(List<int> data) {
    if (data.isNotEmpty) {
      String message = String.fromCharCodes(data);
      print('Received: $message');
      
      if (_timerStatus == TimerStatus.started && !_isPaused) {
        if (message.contains('scissor~')) {
          _incrementCounter('scissor');
        } else if (message.contains('pincher~')) {
          _incrementCounter('pincher');
        } else if (message.contains('pencil_1~')) {
          _incrementCounter('pencil');
        } else if (message.contains('button~')) {
          _incrementCounter('button');
        }
      }
    }
  }

  void _incrementCounter(String type) {
    setState(() {
      switch (type) {
        case 'scissor':
          _countScissor++;
          break;
        case 'pincher':
          _countPincher++;
          break;
        case 'pencil':
          _countPencil++;
          break;
        case 'button':
          _countButton++;
          break;
      }
    });
    
    _playSound(type);
    _sendColorCommand(type);
  }

  Future<void> _playSound(String type) async {
    try {
      String soundFile = _music[type]!;
      await _audioPlayer.setAsset('assets/audio/$soundFile.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _sendColorCommand(String type) async {
    if (_characteristic != null) {
      String colorCode = _colors[type]!;
      await _characteristic!.write(colorCode.codeUnits);
    }
  }

  void _startTimer() {
    if (_selectedDuration > Duration.zero) {
      setState(() {
        _timerStatus = TimerStatus.started;
        _remainingTime = _selectedDuration;
        _isPaused = false;
        // Reset counters
        _countScissor = 0;
        _countPincher = 0;
        _countPencil = 0;
        _countButton = 0;
      });
      
      _startCountdown();
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      if (_timerStatus == TimerStatus.started && !_isPaused) {
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _remainingTime -= Duration(seconds: 1);
          });
          
          if (_remainingTime <= Duration.zero) {
            _timerFinished();
            return false;
          }
        }
        return true;
      }
      return false;
    });
  }

  void _timerFinished() {
    setState(() {
      _timerStatus = TimerStatus.stopped;
    });
    _saveSessionData();
  }

  Future<void> _saveSessionData() async {
    try {
      UserInformation sessionData = UserInformation(
        userName: _userName,
        userAge: await _firebaseService.getUserAge(_userName),
        scissor: _countScissor,
        pencil: _countPencil,
        pincher: _countPincher,
        button: _countButton,
        // sessionDate: DateUtils.getCurrentDate(),
        timer: _selectedDuration.inSeconds,
        createdAt: DateTime.now(), sessionDate: '',
      );
      
      await _firebaseService.addUserInformation(sessionData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session data saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving session: $e')),
      );
    }
  }

  void _pauseResumeTimer() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _stopTimer() {
    setState(() {
      _timerStatus = TimerStatus.stopped;
      _remainingTime = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OT Control'),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/statistics',
                arguments: _userName,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer Display
            _buildTimerDisplay(),
            SizedBox(height: 20),
            
            // Time Selection Buttons
            _buildTimeSelectionButtons(),
            SizedBox(height: 20),
            
            // Control Buttons
            _buildControlButtons(),
            SizedBox(height: 30),
            
            // Counters
            _buildCounters(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _formatDuration(_remainingTime),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              _timerStatus == TimerStatus.started 
                  ? (_isPaused ? 'Paused' : 'Test is running')
                  : 'Please select an interval',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeButton('1 min', Duration(minutes: 1)),
        _buildTimeButton('3 min', Duration(minutes: 3)),
        _buildTimeButton('5 min', Duration(minutes: 5)),
      ],
    );
  }

  Widget _buildTimeButton(String label, Duration duration) {
    bool isSelected = _selectedDuration == duration;
    bool isRunning = _timerStatus == TimerStatus.started;
    
    return ElevatedButton(
      onPressed: isRunning ? null : () {
        setState(() {
          _selectedDuration = duration;
          _remainingTime = duration;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _selectedDuration > Duration.zero ? _startTimer : null,
          child: Text('START'),
        ),
        ElevatedButton(
          onPressed: _timerStatus == TimerStatus.started ? _pauseResumeTimer : null,
          child: Text(_isPaused ? 'RESUME' : 'PAUSE'),
        ),
        ElevatedButton(
          onPressed: _stopTimer,
          child: Text('STOP'),
        ),
      ],
    );
  }

  Widget _buildCounters() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.0,
      children: [
        _buildCounterCard('SCISSOR', _countScissor),
        _buildCounterCard('PINCHER', _countPincher),
        _buildCounterCard('PENCIL', _countPencil),
        _buildCounterCard('BUTTON', _countButton),
      ],
    );
  }

  Widget _buildCounterCard(String title, int count) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('$count', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _device?.disconnect();
    super.dispose();
  }
}

enum TimerStatus { stopped, started }