import 'package:mobile_sensorium/model/acceletometer_data.dart';

enum OrientationState { portrait, landscape, tilted, flat }

class OrientationManager {
  double threshold = 7.0;
  double flatThreshold = 2.0;

  OrientationState determineOrientation(AccelerometerData accelerometerData) {
    if (accelerometerData.x.abs() > threshold &&
        accelerometerData.y.abs() < threshold) {
      return OrientationState.landscape;
    } else if (accelerometerData.y.abs() > threshold &&
        accelerometerData.x.abs() < threshold) {
      return OrientationState.portrait;
    } else if ((accelerometerData.z > 9.0 - flatThreshold) &&
        (accelerometerData.z < 9.0 + flatThreshold)) {
      return OrientationState.flat;
    } else {
      return OrientationState.tilted;
    }
  }
}
