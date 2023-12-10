import 'dart:io';
import 'package:csv/csv.dart';
import 'package:mobile_sensorium/service_locator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:mobile_sensorium/database/accelerometer_db.dart';
import 'package:mobile_sensorium/model/accelerometer_record.dart';

class CSVExporter {
  final db = getIt<AccelerometerDB>();

  Future<String> convertDataToCSV() async {
    List<AccelerometerRecord> records = await db.fetchAllAccelerometerRecords();

    List<List<dynamic>> rows = [
      // Header row
      ['Timestamp', 'X', 'Y', 'Z', 'Orientation', 'Action']
    ];

    for (var record in records) {
      // Data rows
      rows.add([
        record.elapsedMilliseconds,
        record.x,
        record.y,
        record.z,
        record.orientation,
        record.action
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  Future<File> saveCSVToFile(String csvData) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/accelerometer_data.csv';
    final File file = File(path);

    // Write the file
    return file.writeAsString(csvData);
  }

  void shareCSVFile(String filePath) {
    Share.shareFiles([filePath], text: 'Accelerometer Data');
  }
}
