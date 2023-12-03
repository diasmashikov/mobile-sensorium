import 'package:flutter/material.dart';
import 'package:mobile_sensorium/accelerometer_data_display_page.dart';
import 'package:mobile_sensorium/database/accelerometer_db.dart';
import 'package:mobile_sensorium/database/database_service.dart';
import 'package:mobile_sensorium/model/accelerometer_record.dart';
import 'package:mobile_sensorium/model/acceletometer_data.dart';
import 'package:mobile_sensorium/orientation_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  OrientationState _orientationState = OrientationState.portrait;
  double pi = 3.14;

  AccelerometerData _accelerometerData =
      AccelerometerData(x: 0.0, y: 0.0, z: 0.0);

  final OrientationManager _orientationManager = OrientationManager();

  final accelerometerDB = AccelerometerDB();

  bool isCollectingData = false;
  String selectedAction = "walking";
  List<String> actions = ["walking", "running"];

  @override
  void initState() {
    super.initState();

    accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((event) async {
      _accelerometerData =
          AccelerometerData(x: event.x, y: event.y, z: event.z);

      _orientationState =
          _orientationManager.determineOrientation(_accelerometerData);

      if (isCollectingData) {
        final record = AccelerometerRecord(
            timestamp: DateTime.now().toString(),
            x: _accelerometerData.x,
            y: _accelerometerData.y,
            z: _accelerometerData.z,
            orientation: _orientationState.toString(),
            action: selectedAction);
        accelerometerDB.createAccelerometerRecord(record);
      }
    });
  }

  void toggleDataCollection() {
    setState(() {
      isCollectingData = !isCollectingData;
    });
  }

  Stream<int> countStream() async* {
    String tableName = "accelerometer_records";

    yield await accelerometerDB.getCount(tableName);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<int>(
          stream: countStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return Text('Record count: ${snapshot.data}');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const Column(
                children: [],
              );
            }
          },
        ),
        _buildOrientation(),
        const Divider(),
        AccelerometerDataDisplay(),
        DropdownButton<String>(
          value: selectedAction,
          onChanged: (String? newValue) {
            setState(() {
              selectedAction = newValue!;
            });
          },
          items: actions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        OutlinedButton(
          onPressed: toggleDataCollection,
          child: Text(isCollectingData
              ? "Stop Collecting Data"
              : "Start Collecting Data"),
        ),
        OutlinedButton(
          onPressed: () async {
            accelerometerDB.clearDatabase();
          },
          child: const Text("Clear database"),
        ),
      ],
    ));
  }

  Widget _buildOrientation() {
    return Text('Orientation: ${_orientationState.toString().split('.').last}');
  }

  Widget _buildMetrics() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Accelerometer Readings'),
        const SizedBox(height: 20),
        const Text('X-Axis: '),
        LinearProgressIndicator(
          value: normalize(_accelerometerData.x),
          backgroundColor: Colors.amber,
        ),
        Text('${_accelerometerData.x}'),
        const SizedBox(height: 10),
        const Text('Y-Axis: '),
        LinearProgressIndicator(
            value: normalize(_accelerometerData.y),
            backgroundColor: Colors.green),
        Text('${_accelerometerData.y}'),
        const SizedBox(height: 10),
        const Text('Z-Axis: '),
        LinearProgressIndicator(
            value: normalize(_accelerometerData.z),
            backgroundColor: Colors.blue),
        Text('${_accelerometerData.z}'),
        const SizedBox(height: 20),
      ],
    );
  }

  double normalize(double value) {
    return (value + 10) / 20; // Example normalization, adjust as needed
  }
}
