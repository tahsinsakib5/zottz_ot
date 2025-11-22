

import 'package:csv/csv.dart';
import 'package:zottz_ot/firebase_data_model.dart';
// import '../models/user_information.dart';// utils/date_utils.dart


class DateUtils {
  static String getCurrentDate() {
    final now = DateTime.now();
    final month = _getMonthAbbreviation(now.month);
    return '${now.day} $month ${now.year}';
  }

  static String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'JAN';
      case 2: return 'FEB';
      case 3: return 'MAR';
      case 4: return 'APR';
      case 5: return 'MAY';
      case 6: return 'JUN';
      case 7: return 'JUL';
      case 8: return 'AUG';
      case 9: return 'SEP';
      case 10: return 'OCT';
      case 11: return 'NOV';
      case 12: return 'DEC';
      default: return '';
    }
  }
}

// utils/csv_export.dart


class CsvExport {
  static String convertToCsv(List<UserInformation> data) {
    List<List<dynamic>> rows = [];
    
    // Add header
    rows.add([
      'Row ID', 'User Name', 'User Age', 'Scissor', 
      'Pencil', 'Pincher', 'Button', 'Session Date', 'Timer'
    ]);
    
    // Add data rows
    for (var info in data) {
      rows.add([
        info.id,
        info.userName,
        info.userAge,
        info.scissor,
        info.pencil,
        info.pincher,
        info.button,
        info.sessionDate,
        info.timer,
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }
}