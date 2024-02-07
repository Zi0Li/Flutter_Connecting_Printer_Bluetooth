import 'package:flutter_application_2/data/model/printer_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String printerTable = 'printerTable';
const String printerId = 'id';
const String printerName = 'name';
const String printerMac = 'mac';

class PrinterController {
  static final PrinterController _instance = PrinterController.internal();

  factory PrinterController() => _instance;

  PrinterController.internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "printers.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $printerTable($printerId INTEGER PRIMARY KEY, $printerName TEXT, $printerMac TEXT)");
    });
  }

  Future<PrinterModel> saveUser(PrinterModel printer) async {
    Database dbPrinter = await db;
    printer.id = await dbPrinter.insert(printerTable, printer.toMap());

    return printer;
  }

  Future<dynamic> getPrinter() async {
    Database dbPrinter = await db;

    List<Map> maps = await dbPrinter.query(printerTable,
        columns: [
          printerId,
          printerName,
          printerMac,
        ],
        where: "$printerId = ?",
        whereArgs: [1]);
    if (maps.isNotEmpty) {
      return PrinterModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteUser(int id) async {
    Database dbPrinter = await db;
    return await dbPrinter.delete(
      printerTable,
      where: "$printerId = ?",
      whereArgs: [id],
    );
  }

  Future<int> updatePrinter(PrinterModel printer) async {
    Database dbPrinter = await db;
    return await dbPrinter.update(printerTable, printer.toMap(),
        where: "$printerId = ?", whereArgs: [printer.id]);
  }

  Future close() async {
    Database dbUser = await db;
    dbUser.close();
  }

  Future deleteAll() async {
    Database dbPrinter = await db;
    dbPrinter.execute('DELETE FROM $printerTable');
  }
}
