import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  String _accelerometerValues = 'Accelerometer: Unknown';
  String _gyroscopeValues = 'Gyroscope: Unknown';
  String _magnetometerValues = 'Magnetometer: Unknown';

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues =
            'Accelerometer: ${event.x}, ${event.y}, ${event.z}';
      });
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = 'Gyroscope: ${event.x}, ${event.y}, ${event.z}';
      });
    });

    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        _magnetometerValues =
            'Magnetometer: ${event.x}, ${event.y}, ${event.z}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_accelerometerValues),
          Text(_gyroscopeValues),
          Text(_magnetometerValues),
        ],
      ),
    );
  }
}
