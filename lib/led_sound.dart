// screens/led_sound_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class LedSoundScreen extends StatefulWidget {
  final String userName;
  final BluetoothDevice device;

  const LedSoundScreen({
    Key? key,
    required this.userName,
    required this.device,
  }) : super(key: key);

  @override
  _LedSoundScreenState createState() => _LedSoundScreenState();
}

class _LedSoundScreenState extends State<LedSoundScreen> {
  final Map<String, String> _colorMap = {
    'RED': 'A',
    'GREEN': 'B',
    'BLUE': 'C',
    'MAGENTA': 'D',
    'YELLOW': 'E',
    'CYAN': 'F',
    'YELLOW AND MAGENTA': 'G',
    'RED AND BLUE': 'H',
    'BLUE AND RED': 'I',
    'WHITE': 'J',
    'NO COLOR': 'K',
    'RANDOM': 'L',
    'CHANGING COLOR FORWARD': 'M',
    'CHANGING COLOR BACKWARD': 'N',
  };

  final List<String> _musicOptions = [
    'sound1', 'sound2', 'sound3', 'sound4', 'sound5',
    'sound6', 'sound7', 'sound8', 'sound9', 'sound10',
    'sound11', 'sound12', 'sound13', 'sound14', 'sound15',
    'sound16'
  ];

  String _selectedScissorLed = 'RED';
  String _selectedPincherLed = 'CYAN';
  String _selectedPencilLed = 'YELLOW';
  String _selectedButtonLed = 'RED';

  String _selectedScissorMusic = 'sound14';
  String _selectedPincherMusic = 'sound15';
  String _selectedPencilMusic = 'sound11';
  String _selectedButtonMusic = 'sound12';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LED & Sound Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Scissor Settings'),
            _buildLedDropdown('Scissor LED', _selectedScissorLed, (value) {
              setState(() => _selectedScissorLed = value!);
            }),
            _buildMusicDropdown('Scissor Music', _selectedScissorMusic, (value) {
              setState(() => _selectedScissorMusic = value!);
            }),

            _buildSectionHeader('Pincher Settings'),
            _buildLedDropdown('Pincher LED', _selectedPincherLed, (value) {
              setState(() => _selectedPincherLed = value!);
            }),
            _buildMusicDropdown('Pincher Music', _selectedPincherMusic, (value) {
              setState(() => _selectedPincherMusic = value!);
            }),

            _buildSectionHeader('Pencil Settings'),
            _buildLedDropdown('Pencil LED', _selectedPencilLed, (value) {
              setState(() => _selectedPencilLed = value!);
            }),
            _buildMusicDropdown('Pencil Music', _selectedPencilMusic, (value) {
              setState(() => _selectedPencilMusic = value!);
            }),

            _buildSectionHeader('Button Settings'),
            _buildLedDropdown('Button LED', _selectedButtonLed, (value) {
              setState(() => _selectedButtonLed = value!);
            }),
            _buildMusicDropdown('Button Music', _selectedButtonMusic, (value) {
              setState(() => _selectedButtonMusic = value!);
            }),

            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _goToOTControl,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Text('Start OT Session'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildLedDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: _colorMap.keys.map((String color) {
          return DropdownMenuItem<String>(
            value: color,
            child: Text(color),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMusicDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: _musicOptions.map((String music) {
          return DropdownMenuItem<String>(
            value: music,
            child: Text(music),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _goToOTControl() {
    final settings = {
      'userName': widget.userName,
      'device': widget.device,
      'colorScissor': _colorMap[_selectedScissorLed]!,
      'colorPincher': _colorMap[_selectedPincherLed]!,
      'colorPencil': _colorMap[_selectedPencilLed]!,
      'colorButton': _colorMap[_selectedButtonLed]!,
      'musicScissor': _selectedScissorMusic,
      'musicPincher': _selectedPincherMusic,
      'musicPencil': _selectedPencilMusic,
      'musicButton': _selectedButtonMusic,
    };

    Navigator.pushReplacementNamed(
      context,
      '/ot_control',
      arguments: settings,
    );
  }
}