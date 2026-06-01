import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> configureDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}