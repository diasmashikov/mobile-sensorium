import 'package:mobile_sensorium/model/acceletometer_data.dart';
import 'package:mobile_sensorium/orientation_manager.dart';

abstract class SensorEvent {}

class StartDataCollectionEvent extends SensorEvent {}

class StopDataCollectionEvent extends SensorEvent {}
