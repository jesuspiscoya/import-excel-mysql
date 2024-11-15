import 'dart:convert';
import 'dart:io';

import 'package:excel_import_db/model/conection.dart';
import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConectionController {
  Future<MySqlConnection> getConnection(Conection conection) async {
    final ConnectionSettings settings = conection.getConnectionSettings();

    try {
      final conn = await MySqlConnection.connect(settings);
      return conn;
    } on MySqlException catch (e) {
      if (kDebugMode) {
        print("Error al conectar: ${e.message}");
      }
      rethrow;
    }
  }

  Future<String> tryConected(Conection conection) async {
    try {
      final conn = await getConnection(conection);
      conn.close();
      return "Conexión exitosa.";
    } on MySqlException catch (e) {
      return "Error al conectar: ${e.message}";
    } on SocketException catch (e) {
      return "Error al conectar: ${e.message}";
    }
  }

  Future<String> saveConnection(Conection conection) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final conn = await getConnection(conection);
      conn.close();

      if (conection.db == "") {
        throw Exception("No se ha ingresado la base de datos.");
      }
      if (conection.table == "") {
        throw Exception("No se ha ingresado la tabla.");
      }

      await prefs.setString("conection", jsonEncode(conection.toMap()));

      return "Conexión guardada con éxito.";
    } on MySqlException catch (e) {
      return "Error al conectar: ${e.message}";
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
