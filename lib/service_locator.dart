import 'package:get_it/get_it.dart';
import 'package:mobile_sensorium/database/accelerometer_db.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<AccelerometerDB>(AccelerometerDB());
}
