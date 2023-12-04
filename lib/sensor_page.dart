import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_sensorium/accelerometer_data_display_page.dart';
import 'package:mobile_sensorium/bloc/sensor_bloc/sensor_bloc.dart';
import 'package:mobile_sensorium/bloc/sensor_bloc/sensor_event.dart';
import 'package:mobile_sensorium/bloc/sensor_bloc/sensor_state.dart';
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
  late SensorBloc sensorBloc;
  bool isCollectingData = false;
  String selectedAction = "walking";
  List<String> actions = ["walking", "running"];

  @override
  void initState() {
    super.initState();
    sensorBloc = SensorBloc();
  }

  void toggleDataCollection() {
    if (isCollectingData) {
      sensorBloc.add(StopDataCollectionEvent());
    } else {
      sensorBloc.add(StartDataCollectionEvent());
    }
    setState(() {
      isCollectingData = !isCollectingData;
    });
  }

  @override
  void dispose() {
    sensorBloc.close(); // Don't forget to close the BLoC
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sensorBloc,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<SensorBloc, SensorDataState>(
              builder: (context, state) {
                return Text(
                    'Orientation: ${state.orientationState.toString().split('.').last}');
              },
            ),
            const Divider(),
            BlocBuilder<SensorBloc, SensorDataState>(
              builder: (context, state) {
                return _buildMetrics(state.accelerometerData);
              },
            ),
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
                // Clear database logic here
              },
              child: const Text("Clear database"),
            ),
          ],
        ),
      ),
    );
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
