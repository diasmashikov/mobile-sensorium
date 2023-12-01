import 'package:flutter/material.dart';
import 'package:mobile_sensorium/acceletometer_data.dart';
import 'package:mobile_sensorium/orientation_manager.dart';
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

  @override
  void initState() {
    super.initState();

    accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
        .listen((event) {
      setState(() {
        _accelerometerData =
            AccelerometerData(x: event.x, y: event.y, z: event.z);

        _orientationState =
            _orientationManager.determineOrientation(_accelerometerData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildOrientation(), Divider(), _buildMetrics()],
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
