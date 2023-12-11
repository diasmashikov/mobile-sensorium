import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:mobile_sensorium/data_page.dart';
import 'package:mobile_sensorium/database/accelerometer_db.dart';
import 'package:mobile_sensorium/model/accelerometer_record.dart';
import 'package:mobile_sensorium/model/acceletometer_data.dart';
import 'package:mobile_sensorium/orientation_manager.dart';
import 'package:mobile_sensorium/service_locator.dart';

import 'package:sensors_plus/sensors_plus.dart';

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
  int accelerometerRecordCount = 0;
  final accelerometerDB = getIt<AccelerometerDB>();

  bool isSaving = false;
  String selectedAction = 'walking';
  final List<String> actions = ['walking', 'running', 'sitting', 'standing'];

  DateTime? startTime;

  int countdown = 0;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    updateRecordCount();

    accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((event) async {
      setState(() {
        _accelerometerData =
            AccelerometerData(x: event.x, y: event.y, z: event.z);

        _orientationState =
            _orientationManager.determineOrientation(_accelerometerData);
      });

      if (isSaving && startTime != null) {
        final now = DateTime.now();
        final elapsedMilliseconds = now.difference(startTime!).inMilliseconds;

        final record = AccelerometerRecord(
            elapsedMilliseconds: elapsedMilliseconds,
            x: _accelerometerData.x,
            y: _accelerometerData.y,
            z: _accelerometerData.z,
            orientation: _orientationState.toString(),
            action: selectedAction);

        accelerometerDB.createAccelerometerRecord(record);
      }
    });
  }

  void toggleSaving() {
    if (!isSaving) {
      setState(() {
        countdown = 3;
      });
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (countdown > 1) {
          setState(() {
            countdown--;
          });
        } else {
          countdown--;
          setState(() {
            isSaving = true;

            startTime = DateTime.now();
          });
          timer.cancel();
          playStartSound();
        }
      });
    } else {
      setState(() {
        isSaving = false;
        startTime = null;
      });
    }
  }

  Future<void> playStartSound() async {
    try {
      await player.seek(const Duration(milliseconds: 2000));
      await player.play(AssetSource('erzhan_wake_up.mp3'));

      Timer(Duration(seconds: 2), () {
        player.stop(); // This will stop the audio after 3 seconds
      });
    } catch (e) {
      // Handle the error here
      print("Error playing audio: $e");
    }
  }

  Future<void> updateRecordCount() async {
    int count = await accelerometerDB.getCount();
    setState(() {
      accelerometerRecordCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Number of Accelerometer Records: $accelerometerRecordCount'),
        const Divider(),
        _buildOrientation(),
        _buildMetrics(_accelerometerData),
        const Divider(),
        DropdownButton<String>(
            value: selectedAction,
            items: actions
                .map((action) => DropdownMenuItem(
                      value: action,
                      child: Text(action),
                    ))
                .toList(),
            onChanged: (newValue) {
              setState(() {
                selectedAction = newValue!;
              });
            }),
        OutlinedButton(
            onPressed: toggleSaving,
            child: Text(isSaving ? "Stop Saving Data" : "Start Saving Data")),
        if (countdown > 0) Text('The saving starts in $countdown...'),
        if (isSaving)
          Text(
            "Actively saving records for action " + selectedAction,
            style: TextStyle(color: Colors.green),
          ),
        ElevatedButton(
          onPressed: () => navigateToDataPage(context),
          child: const Text('View Data Page'),
        ),
        ElevatedButton(onPressed: playStartSound, child: Text("Make Sound"))
      ],
    ));
  }

  void navigateToDataPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DataPage()),
    );
  }

  Widget _buildOrientation() {
    return Text('Orientation: ${_orientationState.toString().split('.').last}');
  }

  Widget _buildMetrics(AccelerometerData data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Accelerometer Readings'),
        const SizedBox(height: 20),
        const Text('X-Axis: '),
        LinearProgressIndicator(
          value: normalize(data.x),
          backgroundColor: Colors.amber,
        ),
        Text('${data.x}'),
        const SizedBox(height: 10),
        const Text('Y-Axis: '),
        LinearProgressIndicator(
            value: normalize(data.y), backgroundColor: Colors.green),
        Text('${data.y}'),
        const SizedBox(height: 10),
        const Text('Z-Axis: '),
        LinearProgressIndicator(
            value: normalize(data.z), backgroundColor: Colors.blue),
        Text('${data.z}'),
        const SizedBox(height: 20),
      ],
    );
  }

  double normalize(double value) {
    return (value + 10) / 20; // Example normalization, adjust as needed
  }
}
