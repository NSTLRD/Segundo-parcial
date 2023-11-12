import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



class DatabaseHelper{
  static final DatabaseHelper _instance = DatabaseHelper._private();
  DatabaseHelper._private();
  factory DatabaseHelper() => _instance;

  Future<void> initDatabase() async{
    if(_db == null){
      _db = await _initDatabase();
    }
}

Database? _db;

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'Emergencia.db');
    print(path);
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE DataEmergency(Id_Data INTEGER PRIMARY KEY AUTOINCREMENT, Tittle TEXT, Description TEXT, Date TEXT, Photo BLOB)'
        );
      },
    ).then((db) {
      print('Conexion Exitosa con la base de datos');
      return db;
    }).catchError((error) {
      print('Error al intentar conectar la base de datos');
    });
  }

  Future<void> insertEmergency(Emergency emergency) async {
  final db = await _db;
  await db!.insert('DataEmergency', emergency.toMap());
  }

  Future<List<Emergency>> getEmergency() async{
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db!.query('DataEmergency');
    return List.generate(maps.length, (i) {
      return Emergency.fromMap(maps[i]);
    });
  }
}

class Emergency {
  int? id;
  late String title;
  late String date;
  late String description;
  late Uint8List photo;

  Emergency({this.id, required this.title, required this.date, required this.description, required this.photo});

  Map<String, dynamic> toMap() {
    return {
      'Id_Data': id,
      'Tittle': title,
      'Date': date,
      'Description': description,
      'Photo': photo,
    };
  }

  // Define the fromMap factory constructor
  factory Emergency.fromMap(Map<String, dynamic> map) {
    return Emergency(
      id: map['Id_Data'],
      title: map['Tittle'],
      date: map['Date'],
      description: map['Description'],
      photo: map['Photo'],
    );
  }
}