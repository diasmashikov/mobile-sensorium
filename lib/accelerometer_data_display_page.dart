import 'package:flutter/widgets.dart';
import 'package:mobile_sensorium/model/acceletometer_data.dart';

class AccelerometerDataDisplay extends StatefulWidget {
  @override
  _AccelerometerDataDisplayState createState() =>
      _AccelerometerDataDisplayState();
}

class _AccelerometerDataDisplayState extends State<AccelerometerDataDisplay> {
  AccelerometerData _accelerometerData =
      AccelerometerData(x: 0.0, y: 0.0, z: 0.0);

  void updateData(AccelerometerData newData) {
    setState(() {
      _accelerometerData = newData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        "Accelerometer Data: ${_accelerometerData.x}, ${_accelerometerData.y}, ${_accelerometerData.z}");
  }
}
