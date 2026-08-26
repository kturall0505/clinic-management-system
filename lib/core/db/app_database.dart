import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

/// Local-first storage. Each clinic installation keeps its own database file,
/// keyed by tenant id, so data from different clinics is never mixed.
class AppDatabase {
  AppDatabase._(this.db);

  final Database db;

  static Future<AppDatabase> open(String tenantId) async {
    final name = 'clinic_$tenantId.db';
    if (kIsWeb) {
      return AppDatabase._(await databaseFactoryWeb.openDatabase(name));
    }
    final dir = await getApplicationSupportDirectory();
    return AppDatabase._(
        await databaseFactoryIo.openDatabase('${dir.path}/$name'));
  }

  static AppDatabase forTesting(Database db) => AppDatabase._(db);
}
