import 'package:flutter/material.dart';
import 'package:mobile_sensorium/database/accelerometer_db.dart';
import 'package:mobile_sensorium/service_locator.dart';
import 'package:mobile_sensorium/services/csv_exporter.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final List<String> actions = ['walking', 'running', 'sitting', 'standing'];
  Map<String, int> actionCounts = {};
  final accelerometerDB = getIt<AccelerometerDB>();

  @override
  void initState() {
    super.initState();
    fetchActionCounts();
  }

  Future<void> fetchActionCounts() async {
    Map<String, int> counts = {};
    for (var action in actions) {
      final count = await accelerometerDB.getCountByAction(action);
      counts[action] = count;
    }

    setState(() {
      actionCounts = counts;
    });
  }

  Future<void> clearData() async {
    await accelerometerDB.clearDatabase();
    // Refresh UI by resetting actionCounts
    setState(() {
      actionCounts = Map.fromIterable(actions, key: (e) => e, value: (e) => 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Action Counts'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: clearData,
            child: const Text('Clear Data'),
          ),
          ElevatedButton(
            onPressed: () async {
              var exporter = CSVExporter();
              var csvData = await exporter.convertDataToCSV();
              var file = await exporter.saveCSVToFile(csvData);
              exporter.shareCSVFile(file.path);
            },
            child: Text('Export Data'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: actionCounts.length,
              itemBuilder: (context, index) {
                String action = actions[index];
                int count = actionCounts[action] ?? 0;
                return ListTile(
                  title: Text(action),
                  trailing: Text('$count'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
