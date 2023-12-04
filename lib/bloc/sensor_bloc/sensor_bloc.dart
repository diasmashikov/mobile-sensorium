import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_sensorium/bloc/sensor_bloc/sensor_event.dart';
import 'package:mobile_sensorium/bloc/sensor_bloc/sensor_state.dart';
import 'package:mobile_sensorium/model/accelerometer_record.dart';
import 'package:mobile_sensorium/model/acceletometer_data.dart';
import 'package:mobile_sensorium/orientation_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorBloc extends Bloc<SensorEvent, SensorDataState> {
  final OrientationManager _orientationManager = OrientationManager();
  StreamSubscription? _accelerometerSubscription;
  bool _isCollectingData = false;

  SensorBloc()
      : super(SensorDataState(
            accelerometerData: AccelerometerData(x: 0.0, y: 0.0, z: 0.0),
            orientationState: OrientationState.portrait)) {
    _accelerometerSubscription =
        accelerometerEventStream(samplingPeriod: SensorInterval.normalInterval)
            .listen((sensorData) {
      // Always update the state with new sensor data

      AccelerometerData accelerometerData = new AccelerometerData(
          x: sensorData.x, y: sensorData.y, z: sensorData.z);

      final newOrientationState =
          _orientationManager.determineOrientation(accelerometerData);
      add(_InternalUpdateSensorData(accelerometerData, newOrientationState));

      if (_isCollectingData) {
        final record = AccelerometerRecord(
        timestamp: DateTime.now().toString(),
        x: sensorData.x,
        y: sensorData.y,
        z: sensorData.z,
        orientation: _orientationManager.determineOrientation(accelerometerData).toString(),
        action: selectedAction
      );
      accelerometerDB.createAccelerometerRecord(record);
      }
    });

    on<StartDataCollectionEvent>((event, emit) => _isCollectingData = true);
    on<StopDataCollectionEvent>((event, emit) => _isCollectingData = false);
    on<_InternalUpdateSensorData>((event, emit) => emit(SensorDataState(
        accelerometerData: event.accelerometerData,
        orientationState: event.orientationState)));
  }

  void _onStartDataCollection(
      StartDataCollectionEvent event, Emitter<SensorDataState> emit) {
    _isCollectingData = true;
  }

  void _onStopDataCollection(
      StopDataCollectionEvent event, Emitter<SensorDataState> emit) {
    _isCollectingData = false;
  }

  @override
  Future<void> close() {
    _accelerometerSubscription?.cancel();
    return super.close();
  }
}

class _InternalUpdateSensorData extends SensorEvent {
  final AccelerometerData accelerometerData;
  final OrientationState orientationState;

  _InternalUpdateSensorData(this.accelerometerData, this.orientationState);
}
