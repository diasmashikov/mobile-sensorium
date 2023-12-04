import 'package:mobile_sensorium/model/acceletometer_data.dart';
import 'package:mobile_sensorium/orientation_manager.dart';

class SensorDataState {
  final AccelerometerData accelerometerData;
  final OrientationState orientationState;

  SensorDataState(
      {required this.accelerometerData, required this.orientationState});
}
